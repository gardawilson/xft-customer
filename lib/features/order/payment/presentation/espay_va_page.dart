import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/theme/app_colors.dart';
import '../data/order_service.dart';

// Seberapa sering status pembayaran dicek ulang ke backend, supaya customer
// otomatis diarahkan lanjut begitu transfer VA-nya terdeteksi masuk.
const _kStatusPollInterval = Duration(seconds: 5);

class EspayVaPage extends ConsumerStatefulWidget {
  final CheckoutResult checkoutResult;

  const EspayVaPage({super.key, required this.checkoutResult});

  @override
  ConsumerState<EspayVaPage> createState() => _EspayVaPageState();
}

class _EspayVaPageState extends ConsumerState<EspayVaPage> {
  Timer? _pollTimer;
  Timer? _countdownTimer;
  Duration? _remaining;
  bool _isSimulating = false;
  EspayVaOption? _selectedOption;

  @override
  void initState() {
    super.initState();

    final result = widget.checkoutResult;
    if (!result.hasSingleVa && result.vaOptions.isNotEmpty) {
      _selectedOption = result.vaOptions.first;
    }

    if (result.expiredAt != null) {
      _updateRemaining();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
    }

    _pollTimer = Timer.periodic(_kStatusPollInterval, (_) => _checkStatus());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final expiredAt = widget.checkoutResult.expiredAt;
    if (expiredAt == null) return;
    final diff = expiredAt.difference(DateTime.now());
    if (mounted) setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    if (diff.isNegative) _countdownTimer?.cancel();
  }

  Future<void> _checkStatus() async {
    try {
      final status = await ref.read(orderServiceProvider).checkStatus(widget.checkoutResult.orderNumber);
      if (status != 'pending' && mounted) {
        _pollTimer?.cancel();
        context.pushReplacement(
          '/payment-result?status=$status&order_number=${widget.checkoutResult.orderNumber}',
        );
      }
    } catch (_) {
      // biarkan, coba lagi di siklus polling berikutnya
    }
  }

  Future<void> _handleSimulate() async {
    setState(() => _isSimulating = true);
    try {
      await ref.read(orderServiceProvider).simulateEspayPaymentSuccess(widget.checkoutResult.orderNumber);
      // Tidak perlu navigasi manual -- polling yang sudah berjalan akan
      // otomatis mendeteksi perubahan status dalam beberapa detik.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSimulating = false);
    }
  }

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nomor VA disalin ke clipboard')),
    );
  }

  String _formatPrice(num price) {
    final str = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String _formatCountdown(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  static const _bankNames = {
    '014': 'BCA',
    '008': 'Bank Mandiri',
    '002': 'BRI',
    '009': 'BNI',
    '013': 'Permata Bank',
    '022': 'CIMB Niaga',
    '011': 'Bank Danamon',
    '028': 'OCBC NISP',
    '426': 'Bank Mega',
    '441': 'Bank Bukopin',
    '451': 'Bank Syariah Indonesia',
  };
  String _bankName(String? code) => _bankNames[code] ?? (code ?? '-');

  @override
  Widget build(BuildContext context) {
    final result = widget.checkoutResult;
    final needsBankSelection = !result.hasSingleVa && result.vaOptions.isNotEmpty;
    final displayVaNumber = result.hasSingleVa ? result.vaNumber : _selectedOption?.vaNumber;
    final displayBankCode = result.hasSingleVa ? result.bankCode : _selectedOption?.bankCode;

    return Scaffold(
      backgroundColor: AppColors.xftBackground,
      appBar: AppBar(
        backgroundColor: AppColors.xftBackground,
        elevation: 0,
        title: const Text('Pembayaran', style: TextStyle(color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (kDebugMode)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.amber.shade100,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Mode Development — lewati sandbox Espay',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                    TextButton(
                      onPressed: _isSimulating ? null : _handleSimulate,
                      child: _isSimulating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Simulasikan Bayar Sukses',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                    ),
                  ],
                ),
              ),

            if (_remaining != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _remaining == Duration.zero
                      ? AppColors.xftPrimary.withValues(alpha: 0.1)
                      : AppColors.xftAccent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Bayar sebelum', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    Text(
                      _remaining == Duration.zero ? 'Kedaluwarsa' : _formatCountdown(_remaining!),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _remaining == Duration.zero ? AppColors.xftPrimary : AppColors.xftSurface,
                      ),
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.xftAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Tagihan', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    'Rp${_formatPrice(result.totalAmount)}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.xftSurface),
                  ),
                  const SizedBox(height: 20),

                  if (needsBankSelection) ...[
                    const Text('Pilih Bank', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.vaOptions.map((option) {
                        final isSelected = option.bankCode == _selectedOption?.bankCode;
                        return ChoiceChip(
                          label: Text(_bankName(option.bankCode)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedOption = option),
                          showCheckmark: false,
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.xftSurface,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text('Transfer ke Virtual Account ${_bankName(displayBankCode)}',
                      style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            displayVaNumber ?? 'Belum tersedia',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                        IconButton(
                          onPressed: displayVaNumber != null ? () => _copyToClipboard(displayVaNumber) : null,
                          icon: const Icon(Icons.copy_rounded, color: AppColors.xftPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Cara Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.xftSurface)),
            const SizedBox(height: 10),
            const _InstructionStep(number: 1, text: 'Buka aplikasi m-Banking atau ATM bank kamu.'),
            const _InstructionStep(number: 2, text: 'Pilih menu Transfer > Virtual Account.'),
            const _InstructionStep(number: 3, text: 'Masukkan nomor Virtual Account di atas.'),
            const _InstructionStep(number: 4, text: 'Periksa detail tagihan, lalu selesaikan pembayaran.'),
            const _InstructionStep(number: 5, text: 'Halaman ini otomatis lanjut begitu pembayaran terdeteksi.'),

            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
                  Text('Menunggu pembayaran...', style: TextStyle(color: Colors.black.withValues(alpha: 0.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String text;
  const _InstructionStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.xftSurface, shape: BoxShape.circle),
            child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}

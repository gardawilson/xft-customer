import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/api/api_client.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/payment/domain/espay_va_model.dart';

// Seberapa sering status pembayaran dicek ulang ke backend, supaya
// customer otomatis diarahkan lanjut begitu transfer VA-nya terdeteksi
// masuk -- tanpa perlu manual refresh.
const _kStatusPollInterval = Duration(seconds: 5);

class VaPaymentPage extends ConsumerStatefulWidget {
  final EspayPaymentInfo paymentInfo;

  const VaPaymentPage({super.key, required this.paymentInfo});

  @override
  ConsumerState<VaPaymentPage> createState() => _VaPaymentPageState();
}

class _VaPaymentPageState extends ConsumerState<VaPaymentPage> {
  Timer? _pollTimer;
  Timer? _countdownTimer;
  Duration? _remaining;

  // Kalau checkout tidak menentukan bank_code di awal, Espay balikin
  // beberapa pilihan bank sekaligus (semuanya aktif buat order yang sama) --
  // customer pilih salah satu buat ditampilkan nomor VA-nya secara penuh.
  EspayVaOption? _selectedOption;

  @override
  void initState() {
    super.initState();

    if (!widget.paymentInfo.hasSingleVa && widget.paymentInfo.vaOptions.isNotEmpty) {
      _selectedOption = widget.paymentInfo.vaOptions.first;
    }

    if (widget.paymentInfo.expiredAt != null) {
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
    final expiredAt = widget.paymentInfo.expiredAt;
    if (expiredAt == null) return;
    final diff = expiredAt.difference(DateTime.now());
    if (mounted) {
      setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    }
    if (diff.isNegative) {
      _countdownTimer?.cancel();
    }
  }

  Future<void> _checkStatus() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/orders/${widget.paymentInfo.orderNumber}/status');
      final status = response.data['data']?['status'] as String?;

      if (status != null && status != 'pending' && mounted) {
        _pollTimer?.cancel();
        // Pembayaran sudah terdeteksi masuk -- keluar dari halaman VA,
        // balik ke root/tab Pesanan. Sesuaikan route ini dengan struktur
        // navigasi checkout kamu yang sebenarnya.
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran diterima! Pesanan kamu sedang diproses.')),
        );
      }
    } catch (_) {
      // Diamkan -- polling akan coba lagi beberapa detik kemudian.
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

  @override
  Widget build(BuildContext context) {
    final info = widget.paymentInfo;
    final needsBankSelection = !info.hasSingleVa && info.vaOptions.isNotEmpty;
    final displayVaNumber = info.hasSingleVa ? info.vaNumber : _selectedOption?.vaNumber;
    final displayBankCode = info.hasSingleVa ? info.bankCode : _selectedOption?.bankCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Selesaikan Pembayaran'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_remaining != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _remaining == Duration.zero
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : const Color(0xFFFFF8F0),
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
                        color: _remaining == Duration.zero ? AppColors.primary : AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Tagihan', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    'Rp${_formatPrice(info.totalAmount)}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  if (needsBankSelection) ...[
                    const Text('Pilih Bank', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: info.vaOptions.map((option) {
                        final isSelected = option.bankCode == _selectedOption?.bankCode;
                        return ChoiceChip(
                          label: Text(espayBankDisplayName(option.bankCode)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedOption = option),
                          showCheckmark: false,
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.surface,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text('Transfer ke Virtual Account ${espayBankDisplayName(displayBankCode)}',
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
                            displayVaNumber ?? '-',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                        IconButton(
                          onPressed: displayVaNumber != null ? () => _copyToClipboard(displayVaNumber) : null,
                          icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Cara Pembayaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _InstructionStep(number: 1, text: 'Buka aplikasi m-Banking atau ATM bank kamu.'),
            _InstructionStep(number: 2, text: 'Pilih menu Transfer > Virtual Account.'),
            _InstructionStep(number: 3, text: 'Masukkan nomor Virtual Account di atas.'),
            _InstructionStep(number: 4, text: 'Periksa detail tagihan, lalu selesaikan pembayaran.'),
            _InstructionStep(number: 5, text: 'Halaman ini akan otomatis lanjut begitu pembayaran terdeteksi.'),

            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
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
            decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
            child: Text('$number', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:xft/core/theme/app_colors.dart';
import '../data/order_service.dart';

class PaymentWebviewPage extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String orderNumber;

  const PaymentWebviewPage({
    super.key,
    required this.paymentUrl,
    required this.orderNumber,
  });

  @override
  ConsumerState<PaymentWebviewPage> createState() => _PaymentWebviewPageState();
}

class _PaymentWebviewPageState extends ConsumerState<PaymentWebviewPage> {
  late final WebViewController _controller;
  Timer? _pollTimer;
  bool _isChecking = false;
  bool _isSimulating = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentUrl));

    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    if (_isChecking || !mounted) return;
    _isChecking = true;
    try {
      final status = await ref.read(orderServiceProvider).checkStatus(widget.orderNumber);
      if (status != 'pending' && mounted) {
        _pollTimer?.cancel();
        context.pushReplacement(
          '/payment-result?status=$status&order_number=${widget.orderNumber}',
        );
      }
    } catch (_) {
      // biarkan, coba lagi di siklus polling berikutnya
    } finally {
      _isChecking = false;
    }
  }

  Future<void> _handleSimulate() async {
    setState(() => _isSimulating = true);
    try {
      await ref.read(orderServiceProvider).simulatePaymentSuccess(widget.orderNumber);
      // Tidak perlu navigasi manual di sini -- polling yang sudah berjalan
      // akan otomatis mendeteksi perubahan status dalam beberapa detik.
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

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          if (kDebugMode)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Mode Development — lewati sandbox iPaymu',
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
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
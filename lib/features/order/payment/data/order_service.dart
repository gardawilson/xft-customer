import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xft/core/api/api_client.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.watch(dioProvider));
});

/// Satu opsi Virtual Account (dipakai kalau checkout tidak menentukan
/// bank_code di awal -- Espay balikin beberapa pilihan bank sekaligus,
/// semuanya aktif buat order yang sama).
class EspayVaOption {
  final String bankCode;
  final String vaNumber;
  const EspayVaOption({required this.bankCode, required this.vaNumber});

  factory EspayVaOption.fromJson(String bankCode, Map<String, dynamic> json) {
    return EspayVaOption(
      bankCode: bankCode,
      vaNumber: (json['va_number'] ?? '').toString(),
    );
  }
}

/// Hasil dari POST /order/checkout. Isinya beda tergantung
/// `paymentGateway`: 'espay' (Virtual Account) atau 'ipaymu' (WebView).
class CheckoutResult {
  final String orderNumber;
  final String paymentGateway;

  // -- khusus espay --
  final String? vaNumber;
  final String? bankCode;
  final DateTime? expiredAt;
  final num totalAmount;
  final List<EspayVaOption> vaOptions;

  // -- khusus ipaymu (legacy, masih didukung tapi tidak dipakai default) --
  final String? paymentUrl;

  const CheckoutResult({
    required this.orderNumber,
    required this.paymentGateway,
    this.vaNumber,
    this.bankCode,
    this.expiredAt,
    this.totalAmount = 0,
    this.vaOptions = const [],
    this.paymentUrl,
  });

  bool get hasSingleVa => vaNumber != null && vaNumber!.isNotEmpty;

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    final gateway = (json['payment_gateway'] as String?) ?? 'espay';

    final vaListRaw = json['va_list'];
    final vaOptions = <EspayVaOption>[];
    if (vaListRaw is Map) {
      vaListRaw.forEach((key, value) {
        if (value is Map) {
          final option = EspayVaOption.fromJson(key.toString(), Map<String, dynamic>.from(value));
          // Cuma masukkan opsi yang beneran punya nomor VA (skip yang gagal/error).
          if (option.vaNumber.isNotEmpty) vaOptions.add(option);
        }
      });
    }

    return CheckoutResult(
      orderNumber: (json['order_number'] as String?) ?? '-',
      paymentGateway: gateway,
      vaNumber: json['va_number'] as String?,
      bankCode: json['bank_code'] as String?,
      expiredAt: json['expired_at'] != null ? DateTime.tryParse(json['expired_at'].toString()) : null,
      totalAmount: (json['total_amount'] is String)
          ? num.tryParse(json['total_amount']) ?? 0
          : (json['total_amount'] as num? ?? 0),
      vaOptions: vaOptions,
      paymentUrl: json['payment_url'] as String?,
    );
  }
}

class OrderService {
  final Dio _dio;
  OrderService(this._dio);

  /// [paymentMethod] default 'espay' -- kirim 'ipaymu' kalau suatu saat
  /// perlu balik pakai WebView iPaymu lagi.
  Future<CheckoutResult> checkout(
    int outletId, {
    String paymentMethod = 'espay',
    String? bankCode,
  }) async {
    try {
      final response = await _dio.post('/order/checkout', data: {
        'outlet_id': outletId,
        'payment_method': paymentMethod,
        if (bankCode != null) 'bank_code': bankCode,
      });
      return CheckoutResult.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal membuat pesanan');
    }
  }

  /// Mengembalikan status order, mis. 'pending', 'processing', 'completed', 'canceled'.
  Future<String> checkStatus(String orderNumber) async {
    try {
      final response = await _dio.get('/orders/$orderNumber/status');
      return response.data['data']['status'] as String;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal mengecek status pesanan');
    }
  }

  /// DEV-ONLY: memicu simulasi pembayaran sukses tanpa lewat sandbox iPaymu.
  Future<void> simulatePaymentSuccess(String orderNumber) async {
    try {
      await _dio.post('/dev/simulate-payment-success', data: {
        'order_number': orderNumber,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal simulasi pembayaran');
    }
  }

  /// DEV-ONLY: memicu simulasi pembayaran sukses buat order Espay.
  Future<void> simulateEspayPaymentSuccess(String orderNumber) async {
    try {
      await _dio.post('/dev/simulate-payment-success-espay', data: {
        'order_number': orderNumber,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Gagal simulasi pembayaran');
    }
  }
}

/// Satu opsi Virtual Account (dipakai kalau checkout tidak menentukan
/// bank_code di awal -- Espay balikin beberapa pilihan bank sekaligus).
class EspayVaOption {
  final String bankCode;
  final String vaNumber;

  const EspayVaOption({required this.bankCode, required this.vaNumber});

  factory EspayVaOption.fromJson(Map<String, dynamic> json) {
    return EspayVaOption(
      bankCode: (json['bank_code'] ?? json['bankCode'] ?? '').toString(),
      vaNumber: (json['va_number'] ?? json['vaNumber'] ?? json['account_number'] ?? '').toString(),
    );
  }
}

/// Hasil checkout lewat Espay: nomor VA (atau beberapa pilihan bank),
/// jumlah tagihan, dan batas waktu pembayaran.
class EspayPaymentInfo {
  final String orderNumber;
  final String? vaNumber;
  final String? bankCode;
  final DateTime? expiredAt;
  final num totalAmount;
  final List<EspayVaOption> vaOptions;

  const EspayPaymentInfo({
    required this.orderNumber,
    this.vaNumber,
    this.bankCode,
    this.expiredAt,
    required this.totalAmount,
    this.vaOptions = const [],
  });

  bool get hasSingleVa => vaNumber != null && vaNumber!.isNotEmpty;

  factory EspayPaymentInfo.fromCheckoutJson(Map<String, dynamic> json) {
    final vaListRaw = json['va_list'];
    final vaOptions = <EspayVaOption>[];
    if (vaListRaw is List) {
      vaOptions.addAll(
        vaListRaw.whereType<Map>().map((e) => EspayVaOption.fromJson(Map<String, dynamic>.from(e))),
      );
    }

    return EspayPaymentInfo(
      orderNumber: (json['order_number'] as String?) ?? '-',
      vaNumber: json['va_number'] as String?,
      bankCode: json['bank_code'] as String?,
      expiredAt: json['expired_at'] != null ? DateTime.tryParse(json['expired_at'].toString()) : null,
      totalAmount: (json['total_amount'] as num?) ?? 0,
      vaOptions: vaOptions,
    );
  }
}

/// Nama tampilan buat kode bank Espay -- tambahkan sendiri kalau ada bank
/// lain yang belum terdaftar di sini (lihat daftar lengkap di
/// https://docs.espay.id/pg/informasi-umum/kode-bank).
String espayBankDisplayName(String? bankCode) {
  const names = {
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
  return names[bankCode] ?? (bankCode ?? '-');
}

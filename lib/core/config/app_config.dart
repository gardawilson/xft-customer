/// Saklar simpel buat pindah antara server LOCAL (Laragon) dan PRODUCTION
/// (xft.bisagroup.co.id) -- tinggal ganti true/false di sini, nggak perlu
/// comment/uncomment baris baseUrl manual lagi kayak sebelumnya.
library;

/// GANTI JADI true kalau mau app connect ke server production.
/// GANTI JADI false kalau mau connect ke Laragon lokal kamu.
const bool kUseProduction = false;

/// Ganti IP ini setiap kali IP lokal laptop kamu berubah (cek pakai
/// `ipconfig` di Command Prompt) -- ini SATU-SATUNYA tempat yang perlu
/// diedit kalau IP laptop kamu ganti, nggak perlu bongkar api_client.dart.
const String kLocalIp = '127.0.0.1:8000';

const String _localBaseUrl = 'http://$kLocalIp/api';
const String _productionBaseUrl = 'https://xft.bisagroup.co.id/api';

/// Base URL API yang aktif dipakai app sekarang -- otomatis ikut berubah
/// sesuai [kUseProduction] di atas.
const String kApiBaseUrl = kUseProduction ? _productionBaseUrl : _localBaseUrl;

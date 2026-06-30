import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Menangani Deep Link App-to-App untuk menerima permintaan pembayaran dari
/// aplikasi E-Commerce eksternal (mis. ngopss), dan mengirim kembali hasil
/// transaksi ke aplikasi tersebut lewat callback URI.
///
/// kelas ini tidak memanggil navigasi (GoRouter) secara langsung,
/// karena listener-nya hidup di luar widget tree dan pemanggilan navigasi
/// dari sana tidak reliable. Sebagai gantinya, data deep link yang masuk
/// disimpan ke [pendingPayment] (ValueNotifier). Root widget (DompetKampusApp)
/// listen ke notifier ini dan melakukan navigasi dari DALAM widget tree yang
/// sedang hidup, sehingga dijamin selalu berhasil.
///
/// Format URI masuk yang didukung:
///   emoney://pay?merchant=ngopss&order_id=ORD123&amount=18000
///     &description=Bayar+Kopi&callback=ngopss://payment-result
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  /// Data deep link yang sedang menunggu diproses oleh root widget.
  /// null artinya tidak ada permintaan pembayaran yang pending.
  static final ValueNotifier<Map<String, dynamic>?> pendingPayment =
      ValueNotifier(null);

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handleUri(initial);
    } catch (e) {
      debugPrint('[DeepLink] gagal membaca initial link: $e');
    }

    _sub = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (e) => debugPrint('[DeepLink] stream error: $e'),
    );
  }

  void dispose() => _sub?.cancel();

  void _handleUri(Uri uri) {
    debugPrint('[DeepLink] diterima: $uri');

    if (uri.scheme != 'emoney' || uri.host != 'pay') {
      debugPrint('[DeepLink] diabaikan, bukan emoney://pay');
      return;
    }

    final params = uri.queryParameters;
    final amountStr = params['amount'];
    final amount = double.tryParse(amountStr ?? '');

    if (amount == null) {
      debugPrint('[DeepLink] parameter amount tidak valid: $amountStr');
      return;
    }

    final data = {
      'merchant': params['merchant'] ?? 'Merchant',
      'orderId': params['order_id'] ?? '-',
      'amount': amount,
      'description':
          params['description'] ?? 'Pembayaran ${params['merchant'] ?? ''}',
      'callback': params['callback'],
    };

    debugPrint('[DeepLink] set pendingPayment: $data');
    pendingPayment.value = data;
  }

  /// Mengirim hasil transaksi kembali ke aplikasi E-Commerce pemanggil.
  /// [callbackBase] contoh: "ngopss://payment-result"
  static Future<void> sendResult({
    required String callbackBase,
    required bool success,
    String? orderId,
    int? transactionId,
    String? message,
  }) async {
    final uri = Uri.parse(callbackBase).replace(queryParameters: {
      'status': success ? 'success' : 'failed',
      if (orderId != null) 'order_id': orderId,
      if (transactionId != null) 'transaction_id': transactionId.toString(),
      if (message != null) 'message': message,
    });

    debugPrint('[DeepLink] kirim balik: $uri');
    try {
      await launchUrl(uri);
    } catch (e) {
      debugPrint('[DeepLink] gagal mengirim callback: $e');
    }
  }
}

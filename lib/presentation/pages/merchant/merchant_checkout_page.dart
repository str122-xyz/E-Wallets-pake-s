import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';

class MerchantCheckoutPage extends StatelessWidget {
  /// Data dari Deep Link app E-Commerce, contoh struktur:
  /// {
  ///   'merchant': 'ngopss',
  ///   'orderId': 'ORD123',
  ///   'amount': 18000.0,
  ///   'description': 'Pembayaran ngopss #ORD123',
  ///   'callback': 'ngopss://payment-result',
  /// }
  /// Jika null (halaman diakses langsung dari menu, bukan dari Deep Link),
  /// dipakai data simulasi (TokoBelanja) untuk keperluan demo/presentasi.
  final Map<String, dynamic>? deepLinkData;

  const MerchantCheckoutPage({super.key, this.deepLinkData});

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '[DIAGNOSTIC] MerchantCheckoutPage.build() terpanggil, deepLinkData: $deepLinkData');
    final isFromDeepLink = deepLinkData != null;

    final merchantName = isFromDeepLink
        ? (deepLinkData!['merchant'] as String? ?? 'Merchant')
        : 'TokoBelanja';
    final orderId = isFromDeepLink
        ? (deepLinkData!['orderId'] as String? ?? '-')
        : 'TB-2026-88142';
    final description = isFromDeepLink
        ? (deepLinkData!['description'] as String? ??
            'Pembayaran $merchantName')
        : 'TokoBelanja #TB-2026-88142';
    final callback =
        isFromDeepLink ? deepLinkData!['callback'] as String? : null;

    // Item simulasi -- dipakai hanya saat tidak ada data Deep Link asli,
    // karena app E-Commerce eksternal biasanya tidak mengirim rincian item,
    // cukup total amount yang sudah final.
    final items = isFromDeepLink
        ? <Map<String, Object>>[]
        : [
            {
              'name': 'Kopi Hitam Kapal Api (1 dus)',
              'qty': 1,
              'price': 169000.0
            },
            {
              'name': 'Kopi Good Day Capuccino (1 dus)',
              'qty': 1,
              'price': 180000.0
            },
          ];
    const ship = 11000.0;
    final subtotal = items.fold(
        0.0, (s, i) => s + (i['price'] as double) * (i['qty'] as int));
    final total = isFromDeepLink
        ? (deepLinkData!['amount'] as num).toDouble()
        : subtotal + ship;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          // TokoBelanja header (different brand!)
          Container(
            decoration: AppColors.headerPatternDecoration(),
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 6, 16, 14),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: () => context.go('/home'),
                ),
                const Expanded(
                  child: Text('Pembayaran',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      )),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_outlined,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(merchantName,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(
                children: [
                  // Order items
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text('Pesanan #$orderId',
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate400,
                              )),
                        ),
                        if (isFromDeepLink)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: AppColors.violetSurface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                      child: Icon(Icons.receipt_long_outlined,
                                          size: 22, color: AppColors.violet)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(description,
                                      style: const TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      )),
                                ),
                              ],
                            ),
                          )
                        else
                          ...items.asMap().entries.map((e) {
                            final i = e.key;
                            final item = e.value;
                            return Column(
                              children: [
                                if (i > 0)
                                  const Divider(
                                      height: 1, color: AppColors.line2),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 11),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: AppColors.violetSurface,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Center(
                                            child: Icon(
                                                Icons.shopping_bag_outlined,
                                                size: 22,
                                                color: AppColors.violet)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item['name'] as String,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontFamily: 'PlusJakartaSans',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.ink,
                                                )),
                                            Text(
                                                '${item['qty']} × ${CurrencyFormatter.format(item['price'] as double)}',
                                                style: const TextStyle(
                                                    fontSize: 12.5,
                                                    color: AppColors.slate400)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(
                                            (item['price'] as double) *
                                                (item['qty'] as int)),
                                        style: const TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Payment method
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Metode pembayaran',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate400,
                          )),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.shadowSoft,
                      border:
                          Border.all(color: AppColors.primaryLight, width: 1.8),
                    ),
                    child: Row(
                      children: [
                        const AppLogo(size: 40),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Eh-MyWallets',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink,
                                  )),
                              Text('Saldo · pembayaran instan',
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.slate400)),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_rounded,
                            size: 20, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Totals
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.shadowSoft,
                    ),
                    child: Column(
                      children: [
                        if (!isFromDeepLink) ...[
                          _TotalLine(
                              label: 'Subtotal',
                              value: CurrencyFormatter.format(subtotal)),
                          const Divider(height: 1, color: AppColors.line2),
                          _TotalLine(
                              label: 'Ongkos kirim',
                              value: CurrencyFormatter.format(ship)),
                          const Divider(height: 1, color: AppColors.line2),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate600,
                                  )),
                              Text(CurrencyFormatter.format(total),
                                  style: const TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pay bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
            child: AppButton(
              label: 'Bayar ${CurrencyFormatter.format(total)}',
              onPressed: () => context.go('/pin', extra: {
                'kind': 'deeplink',
                'description': description,
                'amount': total,
                'callback': callback,
                'orderId': orderId,
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  final String label;
  final String value;
  const _TotalLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.slate500,
                  fontFamily: 'PlusJakartaSans')),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  fontFamily: 'PlusJakartaSans')),
        ],
      ),
    );
  }
}

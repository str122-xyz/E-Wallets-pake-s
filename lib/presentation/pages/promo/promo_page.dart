import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/feature_icon.dart';

class PromoPage extends StatelessWidget {
  const PromoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final promos = [
      {
        't': 'Cashback 30% Scan QRIS',
        'd': 'Maks. Rp10.000 · s.d. 30 Jun',
        'tone': 'red',
        'icon': Icons.qr_code_scanner_rounded
      },
      {
        't': 'Gratis Biaya Transfer Antarbank',
        'd': 'Bebas kuota tiap bulan',
        'tone': 'green',
        'icon': Icons.send_rounded
      },
      {
        't': 'Diskon 50% Bayar Tagihan PLN',
        'd': 'Khusus pengguna Eh-MyWallets',
        'tone': 'violet',
        'icon': Icons.bolt_rounded
      },
      {
        't': 'Bonus 10.000 Poin Top Up',
        'd': 'Min. top up Rp50.000',
        'tone': 'amber',
        'icon': Icons.account_balance_wallet_rounded
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 12, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Promo & Reward',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.3,
                    )),
                Divider(height: 18, color: AppColors.line2),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: AppColors.headerPatternDecoration(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          AppBadge(label: 'PROMO SPESIAL', tone: 'amber'),
                          SizedBox(height: 12),
                          Text('Transaksi apapun,\npasti makin hemat 💸',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              )),
                          SizedBox(height: 8),
                          Text('Kumpulkan poin di setiap transaksimu.',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 13.5,
                                color: Colors.white70,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ...promos.map((p) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppColors.shadowSoft,
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          FeatureIcon(
                              icon: p['icon'] as IconData,
                              tone: p['tone'] as String,
                              size: 50,
                              iconSize: 24),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['t'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                      height: 1.3,
                                    )),
                                const SizedBox(height: 3),
                                Text(p['d'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12.5,
                                      color: AppColors.slate400,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

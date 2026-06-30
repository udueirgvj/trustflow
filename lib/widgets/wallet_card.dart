import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../theme/app_theme.dart';

class WalletCard extends StatelessWidget {
  final WalletModel wallet;
  const WalletCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.walletStart, AppColors.walletEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.walletStart.withOpacity(0.35),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── الصف العلوي: العنوان + شارة مؤمن ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // شارة مؤمن للعمليات (يسار)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: const [
                    Icon(Icons.shield_outlined,
                        color: Colors.white, size: 14),
                    SizedBox(width: 5),
                    Text('مؤمن للعمليات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      )),
                  ]),
                ),
                // العنوان (يمين)
                const Text('إجمالي الرصيد بالمحفظة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  )),
              ],
            ),

            const SizedBox(height: 10),

            // ── الرصيد الكلي ────────────────────────────────────────────
            Text(
              '\$${wallet.totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 16),

            // ── إحصائيتا الروبوتات ──────────────────────────────────────
            // الترتيب: رأس مال (يسار) | أرباح (يمين)  — كما في الصورة
            Row(
              children: [
                // رأس مال الروبوتات
                Expanded(
                  child: _StatBox(
                    label: 'رأس مال الروبوتات',
                    value: '\$${wallet.robotCapital.toStringAsFixed(2)}',
                    valueColor: Colors.white,
                    icon: Icons.settings,
                  ),
                ),
                const SizedBox(width: 10),
                // أرباح الروبوتات
                Expanded(
                  child: _StatBox(
                    label: 'أرباح الروبوتات',
                    value: '+\$${wallet.robotProfit.toStringAsFixed(2)}',
                    // أصفر/أخضر فاتح كما في الصورة المشار إليها
                    valueColor: const Color(0xFFB9F6CA),
                    icon: Icons.access_time_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color valueColor;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الأيقونة (يسار)
          Icon(icon, color: Colors.white70, size: 20),
          // النص (يمين)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(label,
                style: const TextStyle(
                  color: Colors.white70, fontSize: 10)),
              const SizedBox(height: 3),
              Text(value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
            ],
          ),
        ],
      ),
    );
  }
}

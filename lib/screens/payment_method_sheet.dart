import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'payment_wallet_screen.dart';
import 'payment_bank_card_screen.dart';
import 'payment_crypto_screen.dart';
import 'payment_asiacell_screen.dart';
import 'payment_ether_screen.dart';

class _PayMethod {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  _PayMethod({required this.title, required this.subtitle, required this.icon, required this.color});
}

class PaymentMethodSheet extends StatelessWidget {
  final String robotName;
  final double robotPrice;

  const PaymentMethodSheet({
    super.key,
    required this.robotName,
    required this.robotPrice,
  });

  @override
  Widget build(BuildContext context) {
    final methods = [
      _PayMethod(title: 'محفظة التطبيق', subtitle: 'خصم مباشر من رصيدك الحالي', icon: Icons.account_balance_wallet_outlined, color: Colors.cyan),
      _PayMethod(title: 'البطاقة البنكية', subtitle: 'Visa / Mastercard', icon: Icons.credit_card, color: Colors.orange),
      _PayMethod(title: 'عملات رقمية', subtitle: 'USDT, TRX, TON...', icon: Icons.currency_bitcoin, color: Colors.green),
      _PayMethod(title: 'رصيد آسياسيل', subtitle: 'الدفع المباشر عبر رقم الهاتف', icon: Icons.sim_card, color: Colors.redAccent),
      _PayMethod(title: 'اثير', subtitle: 'تحويل مباشر عبر شبكة Ethereum', icon: Icons.electric_bolt, color: Colors.deepPurpleAccent),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('اختر طريقة الدفع', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('لشراء $robotName بمبلغ \$${robotPrice.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            ...methods.map((m) => ListTile(
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: m.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(m.icon, color: m.color, size: 22),
              ),
              title: Text(m.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              subtitle: Text(m.subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              trailing: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              onTap: () {
                Navigator.pop(context);
                _onMethodSelected(context, m.title);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _onMethodSelected(BuildContext context, String method) {
    switch (method) {
      case 'محفظة التطبيق':
        Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentWalletScreen(robotName: robotName, robotPrice: robotPrice)));
        break;
      case 'البطاقة البنكية':
        Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentBankCardScreen(robotName: robotName, robotPrice: robotPrice)));
        break;
      case 'عملات رقمية':
        Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentCryptoScreen(robotName: robotName, robotPrice: robotPrice)));
        break;
      case 'رصيد آسياسيل':
        Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentAsiacellScreen(robotName: robotName, robotPrice: robotPrice)));
        break;
      case 'اثير':
        Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentEtherScreen(robotName: robotName, robotPrice: robotPrice)));
        break;
    }
  }
}

// دالة مساعدة لفتح الـ Sheet من أي مكان
void showPaymentMethodSheet(BuildContext context, {required String robotName, required double robotPrice}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.bgCard,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => PaymentMethodSheet(robotName: robotName, robotPrice: robotPrice),
  );
}

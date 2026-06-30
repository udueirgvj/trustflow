import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../services/wallet_service.dart';

class PaymentWalletScreen extends StatefulWidget {
  final String robotName;
  final double robotPrice;

  const PaymentWalletScreen({
    super.key,
    required this.robotName,
    required this.robotPrice,
  });

  @override
  State<PaymentWalletScreen> createState() => _PaymentWalletScreenState();
}

class _PaymentWalletScreenState extends State<PaymentWalletScreen> {
  bool _checking = false;

  String get robotName => widget.robotName;
  double get robotPrice => widget.robotPrice;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_forward_ios, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
          centerTitle: true,
          title: const Text('الدفع من المحفظة', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // أيقونة
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.cyan, size: 40),
              ),
              const SizedBox(height: 20),
              // تفاصيل الطلب
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('الروبوت', style: TextStyle(color: AppColors.textSecondary)),
                    Text(robotName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFF2A2A3A)),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('المبلغ المطلوب', style: TextStyle(color: AppColors.textSecondary)),
                    Text('\$${robotPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.cyan.withOpacity(0.2))),
                child: Row(children: [
                  const Icon(Icons.info_outline, color: Colors.cyan, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('سيتم خصم \$${robotPrice.toStringAsFixed(0)} مباشرة من رصيد محفظتك الحالية لشراء روبوت $robotName.', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
                ]),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _checking ? null : () => _confirmPayment(context),
                  icon: _checking
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('تأكيد الدفع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmPayment(BuildContext context) async {
    setState(() => _checking = true);

    final wallet = await WalletService.fetchWallet();

    if (wallet.totalBalance < robotPrice) {
      setState(() => _checking = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رصيدك غير كافٍ'), backgroundColor: Colors.red),
      );
      return;
    }

    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId != null) {
      try {
        await SupabaseService.client.from('purchases').insert({
          'user_id': userId,
          'robot_name': robotName,
          'amount': robotPrice,
          'method': 'wallet',
          'status': 'pending',
        });
      } catch (_) {}
    }

    setState(() => _checking = false);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال طلب شراء $robotName، بانتظار المراجعة'), backgroundColor: Colors.green),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/wallet_service.dart';
import '../models/wallet_model.dart';
import '../models/robot_model.dart';
import '../theme/app_theme.dart';
import '../widgets/wallet_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/robot_performance_card.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';
import 'transfer_screen.dart';
import 'receive_screen.dart';
import 'support_screen.dart';
import 'affiliate_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onGoToStore;
  final VoidCallback? onGoToRobots;
  const HomeScreen({super.key, this.onGoToStore, this.onGoToRobots});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  WalletModel _wallet = WalletModel.zero();
  RobotPerformanceModel _robotData = RobotPerformanceModel.empty();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // بيانات حقيقية من Supabase: الرصيد + رأس مال الروبوتات + أرباحها المتراكمة
      final wallet = await WalletService.fetchWallet();
      // بيانات حقيقية: الروبوتات النشطة + الرسم البياني للأرباح اليومية
      final robotData = await WalletService.fetchRobotPerformance();

      if (!mounted) return;
      setState(() {
        _wallet = wallet;
        _robotData = robotData;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ خطأ: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الرئيسية')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.walletStart))
          : RefreshIndicator(
              color: AppColors.walletStart,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WalletCard(wallet: _wallet),
                    const SizedBox(height: 28),
                    QuickActions(
                      onDeposit: () => DepositScreen.show(context),
                      onWithdraw: () => WithdrawScreen.show(context),
                      onTransfer: () => TransferScreen.show(context),
                      onReceive: () => ReceiveScreen.show(context),
                    ),
                    const SizedBox(height: 24),
                    RobotPerformanceCard(data: _robotData),
                    const SizedBox(height: 28),
                    const Text('استكشف المزيد',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    _ActionCard(
                      icon: Icons.show_chart,
                      iconColor: const Color(0xFF00C8FF),
                      iconBg: const Color(0xFF0D2233),
                      title: 'شارك رابطك واربح معنا!',
                      subtitle: 'نظام مكافآت حصري لدعوة أصدقائك.',
                      buttonText: 'التسويق بالعمولة',
                      buttonColor: const Color(0xFF0D2233),
                      buttonTextColor: const Color(0xFF00C8FF),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AffiliateScreen())),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.smart_toy_outlined,
                      iconColor: AppColors.walletStart,
                      iconBg: const Color(0xFF0D2A20),
                      title: 'مكتبة روبوتات التداول الذكية',
                      subtitle: 'استثمر بذكاء مع أنظمة التداول الآلي.',
                      buttonText: 'متجر الروبوتات',
                      buttonColor: const Color(0xFF0D2A20),
                      buttonTextColor: AppColors.walletStart,
                      onTap: widget.onGoToStore,
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.support_agent,
                      iconColor: AppColors.orange,
                      iconBg: const Color(0xFF2A1A00),
                      title: 'تواصل مع فريق الدعم 24/7',
                      subtitle: 'نحن هنا لمساعدتك في أي استفسار.',
                      buttonText: 'الدعم الفني',
                      buttonColor: const Color(0xFF2A1A00),
                      buttonTextColor: AppColors.orange,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg, buttonColor, buttonTextColor;
  final String title, subtitle, buttonText;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon, required this.iconColor, required this.iconBg,
    required this.title, required this.subtitle, required this.buttonText,
    required this.buttonColor, required this.buttonTextColor, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, textAlign: TextAlign.right,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, textAlign: TextAlign.right,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: buttonTextColor.withOpacity(0.3)),
                      ),
                      child: Text(buttonText,
                          style: TextStyle(color: buttonTextColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

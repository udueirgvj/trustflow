import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/wallet_service.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';
import 'transfer_screen.dart';
import 'receive_screen.dart';
import 'affiliate_screen.dart'; // ✅ أضفنا هذا

// ─── اللون الرئيسي الأخضر ───────────────────────────────────────────────────
const _kAccent = Color(0xFF00C853);
const _kAccentDark = Color(0xFF00952E);

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'المحفظة',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            const _WalletCard(),
            const SizedBox(height: 20),
            _QuickActions(
              onDeposit: () => DepositScreen.show(context),
              onWithdraw: () => WithdrawScreen.show(context),
              onTransfer: () => TransferScreen.show(context),
              onReceive: () => ReceiveScreen.show(context),
            ),
            const SizedBox(height: 16),
            const _ReferralBanner(), // ✅ هنا يفتح AffiliateScreen
            const SizedBox(height: 20),
            const _TransactionLog(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ─── Wallet Card ─────────────────────────────────────────────────────────────

class _WalletCard extends StatefulWidget {
  const _WalletCard();

  @override
  State<_WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<_WalletCard> {
  double _balance = 0.0;
  double _robotProfit = 0.0;
  double _robotCapital = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final wallet = await WalletService.fetchWallet();
      if (!mounted) return;
      setState(() {
        _balance = wallet.totalBalance;
        _robotProfit = wallet.robotProfit;
        _robotCapital = wallet.robotCapital;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kAccent, _kAccentDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kAccent.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text('مؤمن للعمليات', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
              const Text(
                'إجمالي الرصيد بالمحفظة',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '\$${_balance.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'أرباح الروبوتات',
                  value: '+\$${_robotProfit.toStringAsFixed(2)}',
                  valueColor: const Color(0xFFA5FFD6),
                  icon: Icons.access_time_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'رأس مال الروبوتات',
                  value: '\$${_robotCapital.toStringAsFixed(2)}',
                  valueColor: Colors.white,
                  icon: Icons.settings_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  const _MiniStat({
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
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final VoidCallback onDeposit;
  final VoidCallback onWithdraw;
  final VoidCallback onTransfer;
  final VoidCallback onReceive;

  const _QuickActions({
    required this.onDeposit,
    required this.onWithdraw,
    required this.onTransfer,
    required this.onReceive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ActionButton(label: 'إيداع', icon: Icons.add_card_outlined, bgColor: const Color(0xFF0D2B1A), iconColor: _kAccent, onTap: onDeposit),
        _ActionButton(label: 'سحب', icon: Icons.account_balance_wallet_outlined, bgColor: const Color(0xFF2B1A0D), iconColor: AppColors.orange, onTap: onWithdraw),
        _ActionButton(label: 'تحويل', icon: Icons.swap_horiz, bgColor: const Color(0xFF2B1010), iconColor: AppColors.red, onTap: onTransfer),
        _ActionButton(label: 'استلام', icon: Icons.qr_code_2, bgColor: const Color(0xFF0D1F2B), iconColor: const Color(0xFF29B6F6), onTap: onReceive),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.bgColor, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 62, height: 62,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 7),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Referral Banner ──────────────────────────────────────────────────────────

class _ReferralBanner extends StatelessWidget {
  const _ReferralBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // ✅ التعديل هنا
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AffiliateScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: _kAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.bar_chart, color: _kAccent, size: 26),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('شارك رابطك واربح معنا!', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                  SizedBox(height: 3),
                  Text('نظام مكافآت حصري لدعوة أصدقائك.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(border: Border.all(color: _kAccent, width: 1.2), borderRadius: BorderRadius.circular(10)),
              child: const Text('التسويق بالعمولة', style: TextStyle(color: _kAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Transaction Log ──────────────────────────────────────────────────────────

class _TransactionLog extends StatelessWidget {
  const _TransactionLog();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: const [
                  Text('عرض الكل', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 16),
                ],
              ),
            ),
            Row(
              children: [
                const Text('سجل العمليات الأخير', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.receipt_long_outlined, color: _kAccent, size: 18),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 36),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.textSecondary, size: 32),
        ),
        const SizedBox(height: 12),
        const Text('لا توجد عمليات سابقة.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}

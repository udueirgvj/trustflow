import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'payment_wallet_screen.dart';
import 'payment_bank_card_screen.dart';
import 'payment_crypto_screen.dart';
import 'payment_asiacell_screen.dart';
import 'payment_ether_screen.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final robots = [
      _RobotData(name: 'Nova', price: 20.0, dailyProfit: 1.4, capital: 20.0, accuracy: 75, dailyTrades: 2, successRate: 50.0, subscriptionMonths: 1, features: ['سوق الكريبتو', 'إيقاف الخسارة']),
      _RobotData(name: 'Nexus', price: 50.0, dailyProfit: 3.5, capital: 50.0, accuracy: 80, dailyTrades: 4, successRate: 65.0, subscriptionMonths: 1, features: ['سوق الكريبتو', 'إيقاف الخسارة', 'تداول شبكي']),
      _RobotData(name: 'Vertex', price: 100.0, dailyProfit: 6.8, capital: 100.0, accuracy: 85, dailyTrades: 6, successRate: 70.0, subscriptionMonths: 1, features: ['سوق الكريبتو', 'إيقاف الخسارة', 'حماية من الانهيار', 'تداول شبكي']),
      _RobotData(name: 'Apex', price: 250.0, dailyProfit: 12.6, capital: 250.0, accuracy: 88, dailyTrades: 8, successRate: 75.0, subscriptionMonths: 2, features: ['سوق الكريبتو', 'سوق الفوركس', 'إيقاف الخسارة', 'حماية من الانهيار', 'نظام التحوط', 'تداول شبكي']),
      _RobotData(name: 'Quantum', price: 500.0, dailyProfit: 20.6, capital: 500.0, accuracy: 92, dailyTrades: 12, successRate: 82.0, subscriptionMonths: 2, features: ['سوق الكريبتو', 'سوق الفوركس', 'سوق الأسهم', 'إيقاف الخسارة', 'حماية من الانهيار', 'نظام التحوط', 'تداول شبكي', 'تداول إخباري']),
      _RobotData(name: 'Titan', price: 1000.0, dailyProfit: 35.6, capital: 1000.0, accuracy: 95, dailyTrades: 15, successRate: 90.0, subscriptionMonths: 3, features: ['سوق الكريبتو', 'سوق الفوركس', 'سوق الأسهم', 'إيقاف الخسارة', 'حماية من الانهيار', 'تداول عالي التردد', 'تداول شبكي', 'نظام التحوط', 'تداول المراجحة', 'تداول إخباري', 'تأمين التداول', 'رصد السيولة']),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        title: const Text('متجر الروبوتات', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: robots.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) => _RobotCard(robot: robots[i]),
      ),
    );
  }
}

// ─── بطاقة الروبوت ─────────────────────────────────────────────────────────
class _RobotCard extends StatelessWidget {
  final _RobotData robot;
  const _RobotCard({required this.robot});

  void _showPaymentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PaymentMethodSheet(robotName: robot.name, robotPrice: robot.price),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFF1E3A5F), borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  const Text('سعر الروبوت', style: TextStyle(color: Color(0xFF4FC3F7), fontSize: 10)),
                  const SizedBox(height: 2),
                  Text('\$${robot.price.toStringAsFixed(1)}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                ]),
              ),
              const Spacer(),
              Text(robot.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(width: 10),
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: AppColors.bgDark, shape: BoxShape.circle),
                child: const Icon(Icons.smart_toy, color: Colors.cyan, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(textDirection: TextDirection.rtl, children: [
            Expanded(child: _StatChip(label: 'الربح اليومي', value: '~\$${robot.dailyProfit}', icon: Icons.bolt, iconColor: Colors.amber)),
            const SizedBox(width: 8),
            Expanded(child: _StatChip(label: 'رأس المال', value: '\$${robot.capital.toStringAsFixed(1)}', icon: Icons.account_balance_wallet_outlined, iconColor: Colors.purple)),
          ]),
          const SizedBox(height: 8),
          Row(textDirection: TextDirection.rtl, children: [
            Expanded(child: _StatChip(label: 'الدقة', value: '${robot.accuracy}%', icon: Icons.trending_up, iconColor: Colors.green)),
            const SizedBox(width: 8),
            Expanded(child: _StatChip(label: 'الصفقات اليومية', value: '${robot.dailyTrades}', icon: Icons.swap_horiz, iconColor: Colors.purpleAccent)),
          ]),
          const SizedBox(height: 8),
          Row(textDirection: TextDirection.rtl, children: [
            Expanded(child: _StatChip(label: 'النجاح', value: '${robot.successRate}%', icon: Icons.check_circle_outline, iconColor: Colors.green)),
            const SizedBox(width: 8),
            Expanded(child: _StatChip(label: 'الاشتراك', value: '${robot.subscriptionMonths} أشهر', icon: Icons.access_time, iconColor: Colors.orange)),
          ]),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 6, runSpacing: 6,
            children: robot.features.map((f) => _FeatureTag(label: f)).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showPaymentSheet(context),
              icon: const Icon(Icons.credit_card, color: Colors.white, size: 18),
              label: const Text('شراء الروبوت الآن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29B6F6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Sheet اختيار طريقة الدفع ────────────────────────────────────────
class _PaymentMethodSheet extends StatelessWidget {
  final String robotName;
  final double robotPrice;
  const _PaymentMethodSheet({required this.robotName, required this.robotPrice});

  @override
  Widget build(BuildContext context) {
    final methods = [
      {'title': 'محفظة التطبيق',  'subtitle': 'خصم مباشر من رصيدك الحالي',        'icon': Icons.account_balance_wallet_outlined, 'color': Colors.cyan},
      {'title': 'البطاقة البنكية', 'subtitle': 'Visa / Mastercard',                 'icon': Icons.credit_card,                    'color': Colors.orange},
      {'title': 'عملات رقمية',    'subtitle': 'USDT, TRX, TON...',                  'icon': Icons.currency_bitcoin,               'color': Colors.green},
      {'title': 'رصيد آسياسيل',   'subtitle': 'الدفع المباشر عبر رقم الهاتف',      'icon': Icons.sim_card,                       'color': Colors.redAccent},
      {'title': 'اثير',   'subtitle': 'تحويل مباشر عبر شبكة Ethereum',     'icon': Icons.electric_bolt,                  'color': Colors.deepPurpleAccent},
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
                decoration: BoxDecoration(color: (m['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(m['icon'] as IconData, color: m['color'] as Color, size: 22),
              ),
              title: Text(m['title'] as String, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              subtitle: Text(m['subtitle'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              trailing: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              onTap: () {
                Navigator.pop(context);
                _navigate(context, m['title'] as String);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String method) {
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

// ─── Widgets مشتركة ─────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor;
  const _StatChip({required this.label, required this.value, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: AppColors.bgDark, borderRadius: BorderRadius.circular(10)),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          Row(children: [
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 4),
            Icon(icon, color: iconColor, size: 14),
          ]),
        ],
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  final String label;
  const _FeatureTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E7D52), width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
        const SizedBox(width: 4),
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 12),
      ]),
    );
  }
}

class _RobotData {
  final String name;
  final double price, dailyProfit, capital, successRate;
  final int accuracy, dailyTrades, subscriptionMonths;
  final List<String> features;
  _RobotData({required this.name, required this.price, required this.dailyProfit, required this.capital, required this.accuracy, required this.dailyTrades, required this.successRate, required this.subscriptionMonths, required this.features});
}

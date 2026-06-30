// deposit_gateway_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

// ─── موديل بوابة الإيداع ────────────────────────────────────────────────────
class DepositGateway {
  final String id;
  final String name;
  final String subtitle;
  final String iconName; // اسم أيقونة مخزّن في Supabase
  final String colorHex; // لون hex مثل "FF4444"
  final bool isActive;

  DepositGateway({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.iconName,
    required this.colorHex,
    required this.isActive,
  });

  factory DepositGateway.fromMap(Map<String, dynamic> m) => DepositGateway(
        id: m['id']?.toString() ?? '',
        name: m['name'] ?? '',
        subtitle: m['subtitle'] ?? '',
        iconName: m['icon_name'] ?? 'payment',
        colorHex: m['color_hex'] ?? '448AFF',
        isActive: m['is_active'] == true,
      );

  Color get color {
    try {
      return Color(int.parse('FF$colorHex', radix: 16));
    } catch (_) {
      return AppColors.blue;
    }
  }

  IconData get icon {
    switch (iconName) {
      case 'sim_card':        return Icons.sim_card;
      case 'paypal':          return Icons.account_balance_wallet;
      case 'credit_card':     return Icons.credit_card;
      case 'currency_bitcoin':return Icons.currency_bitcoin;
      case 'electric_bolt':   return Icons.electric_bolt;
      case 'phone_android':   return Icons.phone_android;
      case 'qr_code':         return Icons.qr_code;
      case 'bank':            return Icons.account_balance;
      case 'savings':         return Icons.savings;
      default:                return Icons.payment;
    }
  }
}

// ─── الشاشة ─────────────────────────────────────────────────────────────────
class DepositGatewayScreen extends StatefulWidget {
  final double amount;

  const DepositGatewayScreen({super.key, required this.amount});

  static void show(BuildContext context, {required double amount}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DepositGatewayScreen(amount: amount),
    );
  }

  @override
  State<DepositGatewayScreen> createState() => _DepositGatewayScreenState();
}

class _DepositGatewayScreenState extends State<DepositGatewayScreen> {
  List<DepositGateway> _gateways = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGateways();
  }

  Future<void> _loadGateways() async {
    try {
      final data = await SupabaseService.client
          .from('deposit_gateways')
          .select('*')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      if (mounted) {
        setState(() {
          _gateways = (data as List)
              .map((e) => DepositGateway.fromMap(e))
              .toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'تعذّر تحميل البوابات، يرجى المحاولة لاحقاً.';
          _loading = false;
        });
      }
    }
  }

  void _selectGateway(DepositGateway gateway) {
    Navigator.pop(context);
    // هنا ستُضاف الشاشة الخاصة بكل بوابة لاحقاً
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'اخترت: ${gateway.name} — المبلغ: \$${widget.amount.toStringAsFixed(2)}',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: gateway.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 14),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_outlined,
                        color: AppColors.blue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('إيداع الأموال',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(
                        'اختر وسيلة الدفع لإيداع \$${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),

            // Content
            Flexible(
              child: _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: AppColors.blue, strokeWidth: 2),
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.wifi_off,
                                    color: AppColors.textMuted, size: 48),
                                const SizedBox(height: 12),
                                Text(_error!,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _loading = true;
                                      _error = null;
                                    });
                                    _loadGateways();
                                  },
                                  icon: const Icon(Icons.refresh,
                                      color: AppColors.blue),
                                  label: const Text('إعادة المحاولة',
                                      style:
                                          TextStyle(color: AppColors.blue)),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _gateways.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text(
                                  'لا توجد بوابات إيداع متاحة حالياً.',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shrinkWrap: true,
                              itemCount: _gateways.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final g = _gateways[i];
                                return _GatewayTile(
                                  gateway: g,
                                  amount: widget.amount,
                                  onTap: () => _selectGateway(g),
                                );
                              },
                            ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── بطاقة بوابة واحدة ──────────────────────────────────────────────────────
class _GatewayTile extends StatelessWidget {
  final DepositGateway gateway;
  final double amount;
  final VoidCallback onTap;

  const _GatewayTile({
    required this.gateway,
    required this.amount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            // السهم (يسار لأن RTL)
            const Icon(Icons.chevron_left,
                color: AppColors.textMuted, size: 20),

            const SizedBox(width: 8),

            // النصوص
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(gateway.name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 3),
                  Text(gateway.subtitle,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // الأيقونة
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: gateway.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(gateway.icon, color: gateway.color, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

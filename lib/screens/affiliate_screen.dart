import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class AffiliateScreen extends StatefulWidget {
  const AffiliateScreen({super.key});

  @override
  State<AffiliateScreen> createState() => _AffiliateScreenState();
}

class _AffiliateScreenState extends State<AffiliateScreen> {
  final _supabase = Supabase.instance.client;

  double _totalCommission = 0;
  int _activeInvestors = 0;
  int _totalInvited = 0;
  String _referralCode = '';
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAffiliateData();
  }

  Future<void> _loadAffiliateData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // ── 1) جلب رمز الدعوة من profiles أولاً ──────────────────────────────
      String referralCode = '';

      final profileRes = await _supabase
          .from('profiles')
          .select('account_id')
          .eq('id', userId)
          .maybeSingle();

      referralCode = profileRes?['account_id']?.toString() ?? '';

      // إذا ما عنده account_id، ننشئ واحد من الـ UUID
      if (referralCode.isEmpty) {
        referralCode = userId.replaceAll('-', '').substring(0, 8).toUpperCase();
        // نحفظه في profiles
        await _supabase.from('profiles').upsert({
          'id': userId,
          'account_id': referralCode,
        });
      }

      // ── 2) جلب بيانات التسويق من affiliates (اختياري) ────────────────────
      double totalCommission = 0;
      int activeInvestors = 0;
      int totalInvited = 0;

      try {
        final affRes = await _supabase
            .from('affiliates')
            .select('total_commission, active_investors, total_invited')
            .eq('user_id', userId)
            .maybeSingle();

        if (affRes == null) {
          // أنشئ صف جديد لهذا المستخدم
          await _supabase.from('affiliates').upsert({
            'user_id': userId,
            'referral_code': referralCode,
            'total_commission': 0,
            'active_investors': 0,
            'total_invited': 0,
          });
        } else {
          totalCommission = (affRes['total_commission'] as num?)?.toDouble() ?? 0;
          activeInvestors = (affRes['active_investors'] as num?)?.toInt() ?? 0;
          totalInvited = (affRes['total_invited'] as num?)?.toInt() ?? 0;
        }
      } catch (_) {
        // جدول affiliates غير موجود — نكمل بدونه
      }

      // ── 3) جلب آخر العمليات ───────────────────────────────────────────────
      List<Map<String, dynamic>> transactions = [];
      try {
        final txRes = await _supabase
            .from('affiliate_transactions')
            .select('amount, created_at, type')
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(20);
        transactions = List<Map<String, dynamic>>.from(txRes ?? []);
      } catch (_) {
        // جدول affiliate_transactions غير موجود
      }

      if (!mounted) return;
      setState(() {
        _referralCode = referralCode;
        _totalCommission = totalCommission;
        _activeInvestors = activeInvestors;
        _totalInvited = totalInvited;
        _transactions = transactions;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copyCode() {
    if (_referralCode.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ الرمز'),
        backgroundColor: AppColors.walletStart,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'التسويق بالعمولة',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.walletStart))
          : RefreshIndicator(
              color: AppColors.walletStart,
              onRefresh: _loadAffiliateData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ─── بطاقة إجمالي العمولات ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0070E0), Color(0xFF00B4FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'و9',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              const Text(
                                'إجمالي أرباح العمولات',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '\$${_totalCommission.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.bolt,
                                    color: Colors.yellow, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'تضاف أرباحك تلقائياً لمحفظتك',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── إحصائيات ───
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            icon: Icons.group_outlined,
                            iconColor: AppColors.blue,
                            label: 'إجمالي المدعوين',
                            value: '$_totalInvited مستخدم',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatBox(
                            icon: Icons.workspace_premium,
                            iconColor: AppColors.orange,
                            label: 'مستثمر نشط',
                            value: '$_activeInvestors مستخدم',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── رمز الدعوة ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text(
                                'رمز الدعوة الخاص بك',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.link,
                                  color: AppColors.textSecondary, size: 18),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'انسخ الرمز وأرسله لدعوة الفائدة المتبادلة لك ولأصدقائك.',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.bgCardLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // زر نسخ
                                GestureDetector(
                                  onTap: _copyCode,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgCard,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.copy,
                                            color: AppColors.textSecondary,
                                            size: 14),
                                        SizedBox(width: 4),
                                        Text('نسخ',
                                            style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                                // الرمز — يظهر دائماً من profiles
                                Text(
                                  _referralCode.isEmpty
                                      ? '--------'
                                      : _referralCode,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── نظام الفائدة المشتركة ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Icon(Icons.info_outline,
                                  color: AppColors.blue, size: 18),
                              Text(
                                'نظام الفائدة المشتركة المباشر',
                                style: TextStyle(
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _BenefitRow(
                            icon: Icons.person_add_outlined,
                            iconColor: AppColors.walletStart,
                            text:
                                'شارك رمزك لدعوة أصدقائك لإنشاء حساب في التطبيق.',
                          ),
                          const SizedBox(height: 10),
                          _BenefitRow(
                            icon: Icons.account_balance_wallet_outlined,
                            iconColor: AppColors.blue,
                            text:
                                'سيحصل صديقك المدعو على \$1 كرصيد ترحيبي مباشرة في محفظته.',
                          ),
                          const SizedBox(height: 10),
                          _BenefitRow(
                            icon: Icons.bar_chart,
                            iconColor: AppColors.orange,
                            text:
                                'ستحصل أنت على عمولة مستمرة قدرها 5% (بحد أقصى \$25)، في كل مرة يقوم فيها صديقك بشراء روبوت استثماري جديد.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── آخر العمليات ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.06),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'عرض الكل',
                                style: TextStyle(
                                    color: AppColors.blue, fontSize: 12),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'آخر العمليات',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.receipt_long_outlined,
                                      color: AppColors.textSecondary, size: 18),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _transactions.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Text(
                                      'لا توجد عمليات سابقة.',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: _transactions.map((tx) {
                                    final amount =
                                        (tx['amount'] as num?)?.toDouble() ??
                                            0;
                                    final date = tx['created_at'] != null
                                        ? DateTime.parse(tx['created_at'])
                                            .toLocal()
                                        : null;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '+\$${amount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: AppColors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            date != null
                                                ? '${date.year}/${date.month}/${date.day}'
                                                : '',
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── مربع إحصائية ────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── صف ميزة ─────────────────────────────────────────────────────────────────
class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _BenefitRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12, height: 1.5),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
      ],
    );
  }
}

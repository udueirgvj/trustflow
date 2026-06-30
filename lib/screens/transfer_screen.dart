import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TransferScreen(),
    );
  }

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amountCtrl    = TextEditingController();
  final _recipientCtrl = TextEditingController();
  bool _loading  = false;
  String? _error;

  // رسوم التحويل الداخلي 1%
  static const double _feeRate = 0.01;
  static const double _minTransfer = 5.0;
  static const double _maxTransfer = 1000.0;

  double get _amount    => double.tryParse(_amountCtrl.text) ?? 0;
  double get _fee       => _amount * _feeRate;
  double get _netAmount => _amount - _fee;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
              )),
              const SizedBox(height: 20),

              // Title
              const Center(
                child: Text('تحويل الرصيد',
                  style: TextStyle(color: AppColors.textPrimary,
                    fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'يتم تحويل الرصيد فوراً إلى المحفظة المستهدفة.\nعمولة الشبكة الداخلية 1% بحدود تحويل (\$5 إلى \$1000).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Recipient field
              _buildLabel('معرّف المستلم (User ID)'),
              const SizedBox(height: 8),
              _buildField(
                controller: _recipientCtrl,
                hint: 'معرّف المستلم (User ID)',
                keyboardType: TextInputType.text,
                prefixIcon: Icons.person_outline,
                suffixIcon: Icons.qr_code_scanner,
                onSuffixTap: () { /* TODO: QR scanner */ },
              ),
              const SizedBox(height: 16),

              // Amount field
              _buildLabel('المبلغ المراد تحويله (\$)'),
              const SizedBox(height: 8),
              _buildField(
                controller: _amountCtrl,
                hint: 'المبلغ المراد تحويله (\$)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.attach_money,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // Fee breakdown
              if (_amount > 0) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(children: [
                    _feeRow('المبلغ', '\$${ _amount.toStringAsFixed(2)}'),
                    const Divider(color: Colors.white12, height: 16),
                    _feeRow('رسوم التحويل (1%)', '-\$${_fee.toStringAsFixed(2)}',
                      valueColor: AppColors.red),
                    const Divider(color: Colors.white12, height: 16),
                    _feeRow('سيستلم المستلم', '\$${_netAmount.toStringAsFixed(2)}',
                      valueColor: AppColors.greenLight,
                      isBold: true),
                  ]),
                ),
                const SizedBox(height: 12),
              ],

              // Error
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.red.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: AppColors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!,
                      style: const TextStyle(color: AppColors.red, fontSize: 13))),
                  ]),
                ),
                const SizedBox(height: 12),
              ],

              // Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _handleTransfer,
                  icon: _loading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  label: Text(_loading ? 'جارٍ التحويل...' : 'متابعة التدقيق',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                      color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.walletStart,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── التحويل الحقيقي عبر Supabase (RPC transaction واحدة) ─────────────────
  Future<void> _handleTransfer() async {
    final recipientId = _recipientCtrl.text.trim();
    final amount      = _amount;

    // ── التحقق من المدخلات ──
    if (recipientId.isEmpty) {
      setState(() => _error = 'يرجى إدخال معرّف المستلم'); return;
    }
    if (amount < _minTransfer) {
      setState(() => _error = 'الحد الأدنى للتحويل \$$_minTransfer'); return;
    }
    if (amount > _maxTransfer) {
      setState(() => _error = 'الحد الأقصى للتحويل \$$_maxTransfer'); return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final client   = SupabaseService.client;
      final senderId = client.auth.currentUser?.id;
      if (senderId == null) throw Exception('غير مسجّل الدخول');

      // كل المنطق (التحقق من الرصيد + الخصم + الإضافة + التسجيل)
      // يصير داخل دالة واحدة بقاعدة البيانات (transfer_balance) لضمان
      // أن العملية كاملة تنجح أو تفشل كاملة، وما يحصل خصم بدون إضافة.
      final result = await client.rpc('transfer_balance', params: {
        'p_sender_id': senderId,
        'p_recipient_code': recipientId,
        'p_amount': amount,
      });

      final netReceived = (result['net_amount'] as num).toDouble();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'تم التحويل بنجاح ✅  |  استلم: \$${netReceived.toStringAsFixed(2)}',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: AppColors.walletStart,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));

    } on PostgrestException catch (e) {
      setState(() { _error = _mapError(e.message); });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ترجمة أكواد الأخطاء القادمة من دالة قاعدة البيانات لرسائل عربية واضحة
  String _mapError(String message) {
    if (message.contains('INSUFFICIENT_BALANCE')) {
      return 'رصيدك غير كافٍ للتحويل';
    }
    if (message.contains('RECIPIENT_NOT_FOUND')) {
      return 'معرّف المستلم غير موجود';
    }
    if (message.contains('SENDER_NOT_FOUND')) {
      return 'لم يتم العثور على محفظتك';
    }
    if (message.contains('SELF_TRANSFER')) {
      return 'لا يمكن التحويل لنفس الحساب';
    }
    return 'خطأ في قاعدة البيانات: $message';
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _buildLabel(String text) => Text(text,
    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13));

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required IconData prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        textAlign: TextAlign.right,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Icon(suffixIcon, color: AppColors.walletStart, size: 22))
              : null,
        ),
      ),
    );
  }

  Widget _feeRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(value, style: TextStyle(
        color: valueColor ?? AppColors.textPrimary,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: isBold ? 15 : 13,
        fontFamily: 'Inter',
      )),
      Text(label, style: const TextStyle(
        color: AppColors.textSecondary, fontSize: 13)),
    ]);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _recipientCtrl.dispose();
    super.dispose();
  }
}

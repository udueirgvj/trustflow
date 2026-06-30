import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

// ─── خدمة إيثر — نفس API آسياسيل، تستخدم توكن المالك المخزّن مسبقاً ──────────
class _EtherService {
  static const _apiKey  = '1ccbc4c913bc4ce785a0a2de444aa0d6';
  static const _baseUrl = 'https://odpapp.asiacell.com/api/v1';

  static Map<String, String> _h({String? token}) => {
    'X-ODP-API-KEY': _apiKey,
    'DeviceID': '86b73a89-feec-4202-9ab5-35920aec739c',
    'X-OS-Version': '12',
    'X-Device-Type': '[Android][INFINIX][Infinix X665E 12][S]',
    'X-ODP-APP-VERSION': '5.0.8',
    'X-FROM-APP': 'odp',
    'X-ODP-CHANNEL': 'mobile',
    'X-SCREEN-TYPE': 'MOBILE',
    'Content-Type': 'application/json; charset=UTF-8',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<Map<String, dynamic>> _post(String url, Map body, {String? token}) async {
    final res = await http.post(Uri.parse(url), headers: _h(token: token), body: jsonEncode(body));
    return jsonDecode(res.body);
  }

  // تحويل المبلغ من رصيد المالك إلى الرقم المستلم — باستخدام توكن المالك المخزّن
  static Future<_EtherResult> startTransfer(String ownerToken, String receiverNumber, String amount) async {
    try {
      final d = await _post('$_baseUrl/credit-transfer/start?lang=en',
          {'receiverMsisdn': receiverNumber, 'amount': amount}, token: ownerToken);
      if (d['success'] == true) return _EtherResult(success: true, pid: d['PID']?.toString());
      return _EtherResult(success: false, error: d['message']?.toString() ?? 'رصيد غير كافٍ أو خطأ في التحويل');
    } catch (e) {
      return _EtherResult(success: false, error: 'خطأ في الاتصال: $e');
    }
  }
}

class _EtherResult {
  final bool success;
  final String? pid;
  final String? error;
  _EtherResult({required this.success, this.pid, this.error});
}

// ─── الشاشة — صفحة واحدة فقط، بنفس أسلوب شاشة آسياسيل ──────────────────────
class PaymentEtherScreen extends StatefulWidget {
  final String robotName;
  final double robotPrice;
  const PaymentEtherScreen({super.key, required this.robotName, required this.robotPrice});

  @override
  State<PaymentEtherScreen> createState() => _PaymentEtherScreenState();
}

class _PaymentEtherScreenState extends State<PaymentEtherScreen> {
  final _numberCtrl = TextEditingController();
  bool _loading = false;
  bool _done = false;
  String _ownerToken = '';
  String _ownerNumber = '';

  @override
  void initState() {
    super.initState();
    _loadOwnerSettings();
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    super.dispose();
  }

  // يتم تعبئة هذه القيم من تطبيق المالك (لوحة الإعدادات) وتُخزَّن في Supabase
  Future<void> _loadOwnerSettings() async {
    try {
      final res = await SupabaseService.client
          .from('owner_settings')
          .select('ether_token, ether_number')
          .maybeSingle();
      if (res != null) {
        setState(() {
          _ownerToken = res['ether_token'] ?? '';
          _ownerNumber = res['ether_number'] ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    final number = _numberCtrl.text.trim();
    if (number.isEmpty) {
      _showError('يرجى إدخال رقم الهاتف المستلم');
      return;
    }
    if (_ownerToken.isEmpty) {
      _showError('خدمة الدفع غير متاحة حالياً، تواصل مع الدعم');
      return;
    }

    setState(() => _loading = true);

    final r = await _EtherService.startTransfer(
      _ownerToken,
      number,
      widget.robotPrice.toStringAsFixed(0),
    );

    if (r.success) {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId != null) {
        try {
          await SupabaseService.client.from('purchases').insert({
            'user_id': userId,
            'robot_name': widget.robotName,
            'amount': widget.robotPrice,
            'method': 'ether',
            'phone': number,
            'status': 'completed',
          });
        } catch (_) {}
      }
      setState(() {
        _done = true;
        _loading = false;
      });
    } else {
      _showError(r.error ?? 'فشل التحويل');
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
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
          title: const Text('دفع إيثر',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        ),
        body: _done ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // بطاقة سعر الروبوت
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy_outlined, color: Colors.deepPurpleAccent, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(widget.robotName,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('\$${widget.robotPrice.toStringAsFixed(0)} :السعر',
                        style: const TextStyle(color: Colors.deepPurpleAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // شرح الدفع
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text('كيفية الدفع',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(width: 8),
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                _step('1', 'أدخل رقم هاتف خط إيثر الخاص بك في الخانة أدناه'),
                _step('2', 'اضغط "دفع الآن"'),
                _step('3', 'سيتم تحويل \$${widget.robotPrice.toStringAsFixed(0)} إلى رقمك تلقائياً'),
                _step('4', 'سيتم تفعيل الروبوت فور نجاح التحويل'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // خانة رقم الهاتف
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('رقم الهاتف',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('أدخل رقم خط إيثر الذي تريد استلام التحويل عليه',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 12),
                TextField(
                  controller: _numberCtrl,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '07XXXXXXXXX',
                    hintStyle: const TextStyle(color: AppColors.textSecondary, letterSpacing: 2),
                    filled: true,
                    fillColor: AppColors.bgDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // زر الدفع
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('دفع الآن',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _step(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(text,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.right),
          ),
          const SizedBox(width: 8),
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
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
                color: Colors.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 24),
            const Text('تم الدفع بنجاح! ✅',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 8),
            Text('تم تفعيل روبوت ${widget.robotName}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
}
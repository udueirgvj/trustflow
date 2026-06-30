import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

class PaymentAsiacellScreen extends StatefulWidget {
  final String robotName;
  final double robotPrice;

  const PaymentAsiacellScreen({
    super.key,
    required this.robotName,
    required this.robotPrice,
  });

  @override
  State<PaymentAsiacellScreen> createState() => _PaymentAsiacellScreenState();
}

class _PaymentAsiacellScreenState extends State<PaymentAsiacellScreen> {
  static const String _apiKey = '1ccbc4c913bc4ce785a0a2de444aa0d6';
  static const String _baseUrl = 'https://odpapp.asiacell.com/api/v1';

  final _cardCtrl = TextEditingController();
  bool _loading = false;
  bool _done = false;
  String _ownerToken = '';
  String _ownerPhone = '';
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOwnerSettings();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOwnerSettings() async {
    try {
      final res = await SupabaseService.client
          .from('owner_settings')
          .select('asiacell_token, asiacell_number')
          .maybeSingle();
      if (res != null) {
        setState(() {
          _ownerToken = res['asiacell_token'] ?? '';
          _ownerPhone = res['asiacell_number'] ?? '';
        });
      }
    } catch (_) {}
  }

  String _generateDeviceId() {
    final rand = Random();
    final part = List.generate(4, (_) => rand.nextInt(10)).join();
    return '86b73a89-feec-$part-9ab5-35920aec739c';
  }

  Map<String, String> _headers({String? token}) {
    final h = <String, String>{
      'X-ODP-API-KEY': _apiKey,
      'DeviceID': _generateDeviceId(),
      'X-OS-Version': '12',
      'X-Device-Type': '[Android][INFINIX][Infinix X665E 12][S]',
      'X-ODP-APP-VERSION': '5.0.8',
      'X-FROM-APP': 'odp',
      'X-ODP-CHANNEL': 'mobile',
      'X-SCREEN-TYPE': 'MOBILE',
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<void> _submit() async {
    final card = _cardCtrl.text.trim();
    if (card.isEmpty) {
      _showError('يرجى إدخال رقم الكارت');
      return;
    }
    if (_ownerToken.isEmpty) {
      _showError('خدمة الشحن غير متاحة حالياً، تواصل مع الدعم');
      return;
    }

    setState(() {
      _loading = true;
      _statusMessage = 'جاري شحن الكارت...';
    });

    try {
      // شحن الكارت باستخدام Token المالك
      final res = await http.post(
        Uri.parse('$_baseUrl/topup/scratch-card?lang=en'),
        headers: _headers(token: _ownerToken),
        body: jsonEncode({'scratchCode': card}),
      );

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        // حفظ العملية في قاعدة البيانات
        final userId = SupabaseService.client.auth.currentUser?.id;
        if (userId != null) {
          await SupabaseService.client.from('purchases').insert({
            'user_id': userId,
            'robot_name': widget.robotName,
            'amount': widget.robotPrice,
            'method': 'asiacell_card',
            'card_number': card,
            'status': 'completed',
          });
        }
        setState(() {
          _done = true;
          _loading = false;
        });
      } else {
        final msg = data['message']?.toString() ?? 'فشل شحن الكارت';
        _showError(msg);
        setState(() => _loading = false);
      }
    } catch (e) {
      _showError('خطأ في الاتصال، حاول مرة أخرى');
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
          title: const Text(
            'دفع آسياسيل',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
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
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy_outlined, color: Colors.redAccent, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(widget.robotName,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('\$${widget.robotPrice.toStringAsFixed(0)} :السعر',
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.bold)),
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
                _step('1', 'اشترِ كارت شحن آسياسيل بقيمة \$${widget.robotPrice.toStringAsFixed(0)}'),
                _step('2', 'اكشط الكارت للحصول على الرقم السري'),
                _step('3', 'أدخل رقم الكارت في الخانة أدناه'),
                _step('4', 'اضغط "تعبئة الآن" وسيتم الشحن تلقائياً'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // خانة رقم الكارت
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('رقم الكارت',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                const Text('أدخل الرقم السري الموجود على الكارت',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 12),
                TextField(
                  controller: _cardCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'XXXX-XXXX-XXXX',
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

          // زر التعبئة
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                        if (_statusMessage.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(_statusMessage, style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ],
                    )
                  : const Text('تعبئة الآن',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String number, String text) {
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
            const Text('تم الشحن بنجاح! ✅',
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

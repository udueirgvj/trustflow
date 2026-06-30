import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class AsiacellService {
  static const String _apiKey = '1ccbc4c913bc4ce785a0a2de444aa0d6';
  static const String _baseUrl = 'https://odpapp.asiacell.com/api/v1';
  static const String _receiverPhone = '7783872738';

  static String _generateDeviceId() {
    final rand = Random();
    final part = List.generate(4, (_) => rand.nextInt(10)).join();
    return '86b73a89-feec-$part-9ab5-35920aec739c';
  }

  static Map<String, String> _headers({String? token}) {
    final headers = <String, String>{
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
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  // تحويل الرقم لصيغة آسياسيل الصحيحة
  static String _formatPhone(String phone) {
    phone = phone.trim().replaceAll(' ', '').replaceAll('-', '');
    if (phone.startsWith('00964')) return phone.substring(5);
    if (phone.startsWith('+964')) return phone.substring(4);
    if (phone.startsWith('964')) return phone.substring(3);
    if (phone.startsWith('0')) return phone.substring(1);
    return phone;
  }

  // الخطوة 1: إرسال الرقم → SMS
  static Future<AsiacellResult> login(String phoneNumber) async {
    try {
      final formatted = _formatPhone(phoneNumber);
      print('🔵 Asiacell login: formatted=$formatted');
      final res = await http.post(
        Uri.parse('$_baseUrl/login?lang=en'),
        headers: _headers(),
        body: jsonEncode({'captchaCode': '', 'username': formatted}),
      );
      print('🔵 Asiacell login response: ${res.statusCode} ${res.body}');
      final data = jsonDecode(res.body);
      if (data['nextUrl'] != null) {
        final pid = (data['nextUrl'] as String).split('=').last;
        return AsiacellResult(success: true, pid: pid);
      }
      final errMsg = data['message']?.toString() ?? data['error']?.toString() ?? 'فشل إرسال رمز SMS';
      return AsiacellResult(success: false, error: errMsg);
    } catch (e) {
      print('🔴 Asiacell login error: $e');
      return AsiacellResult(success: false, error: 'خطأ في الاتصال: $e');
    }
  }

  // الخطوة 2: التحقق من كود SMS → Token
  static Future<AsiacellResult> verifySms(String pid, String code) async {
    try {
      print('🔵 Asiacell verifySms: pid=$pid code=$code');
      final res = await http.post(
        Uri.parse('$_baseUrl/smsvalidation?lang=en'),
        headers: _headers(),
        body: jsonEncode({
          'PID': pid,
          'passcode': code,
          'token': 'eYIPfXJTQ6aULUnLNWF8cV:APA91bGFr_3ySwVZvGBlAstaHjXKj8IKFiR7mEb4MjxnrDHi-x-rHMQgggUd5xOqOKiD_gGb7Z69kDtETLnNk6NjILHJhQAyMsx0FaDfmUGYciqC7jhXdwrwm0b82T_ymDz9JwgvmSc3',
        }),
      );
      print('🔵 Asiacell verifySms response: ${res.statusCode} ${res.body}');
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return AsiacellResult(success: true, token: data['access_token']);
      }
      final errMsg = data['message']?.toString() ?? 'كود خاطئ، حاول مجدداً';
      return AsiacellResult(success: false, error: errMsg);
    } catch (e) {
      print('🔴 Asiacell verifySms error: $e');
      return AsiacellResult(success: false, error: 'خطأ في الاتصال: $e');
    }
  }

  // الخطوة 3: بدء التحويل
  static Future<AsiacellResult> startTransfer(String token, String amount) async {
    try {
      print('🔵 Asiacell startTransfer: amount=$amount receiver=$_receiverPhone');
      final res = await http.post(
        Uri.parse('$_baseUrl/credit-transfer/start?lang=en'),
        headers: _headers(token: token),
        body: jsonEncode({
          'receiverMsisdn': _receiverPhone,
          'amount': amount,
        }),
      );
      print('🔵 Asiacell startTransfer response: ${res.statusCode} ${res.body}');
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return AsiacellResult(success: true, pid: data['PID']?.toString());
      }
      final msg = data['message']?.toString() ?? 'رصيد غير كافٍ أو خطأ في التحويل';
      return AsiacellResult(success: false, error: msg);
    } catch (e) {
      print('🔴 Asiacell startTransfer error: $e');
      return AsiacellResult(success: false, error: 'خطأ في الاتصال: $e');
    }
  }

  // الخطوة 4: تأكيد التحويل
  static Future<AsiacellResult> confirmTransfer(String token, String pid, String code) async {
    try {
      print('🔵 Asiacell confirmTransfer: pid=$pid code=$code');
      final res = await http.post(
        Uri.parse('$_baseUrl/credit-transfer/do-transfer?lang=en'),
        headers: _headers(token: token),
        body: jsonEncode({'PID': pid, 'passcode': code}),
      );
      print('🔵 Asiacell confirmTransfer response: ${res.statusCode} ${res.body}');
      final data = jsonDecode(res.body);
      if (data['success'] == true) {
        return AsiacellResult(success: true);
      }
      final msg = data['message']?.toString() ?? 'فشل التأكيد، حاول مجدداً';
      return AsiacellResult(success: false, error: msg);
    } catch (e) {
      print('🔴 Asiacell confirmTransfer error: $e');
      return AsiacellResult(success: false, error: 'خطأ في الاتصال: $e');
    }
  }
}

class AsiacellResult {
  final bool success;
  final String? pid;
  final String? token;
  final String? error;
  AsiacellResult({required this.success, this.pid, this.token, this.error});
}

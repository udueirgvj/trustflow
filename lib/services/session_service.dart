import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'supabase_service.dart';

class LoginSessionInfo {
  final String id;
  final String deviceName;
  final String platform;
  final String? osVersion;
  final String? appVersion;
  final bool isCurrent;
  final DateTime createdAt;

  LoginSessionInfo({
    required this.id,
    required this.deviceName,
    required this.platform,
    this.osVersion,
    this.appVersion,
    required this.isCurrent,
    required this.createdAt,
  });

  factory LoginSessionInfo.fromMap(Map<String, dynamic> map) {
    return LoginSessionInfo(
      id: map['id'] as String,
      deviceName: map['device_name'] as String? ?? 'جهاز غير معروف',
      platform: map['platform'] as String? ?? '',
      osVersion: map['os_version'] as String?,
      appVersion: map['app_version'] as String?,
      isCurrent: map['is_current'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class SessionService {
  /// يسجّل جلسة دخول جديدة بمعلومات الجهاز الحقيقية.
  /// يُستدعى بعد signIn أو signUp الناجح.
  static Future<void> recordCurrentSession() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    String deviceName = 'جهاز غير معروف';
    String platform = 'Unknown';
    String? osVersion;

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        deviceName = '${info.manufacturer} ${info.model}';
        platform = 'Android';
        osVersion = 'Android ${info.version.release}';
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        deviceName = info.utsname.machine;
        platform = 'iOS';
        osVersion = info.systemVersion;
      } else {
        platform = Platform.operatingSystem;
      }
    } catch (_) {
      // لو فشل قراءة معلومات الجهاز، نكمل بالقيم الافتراضية
    }

    String? appVersion;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
    } catch (_) {}

    try {
      // أي جلسة سابقة تصير غير حالية
      await SupabaseService.client
          .from('login_sessions')
          .update({'is_current': false})
          .eq('user_id', user.id);

      await SupabaseService.client.from('login_sessions').insert({
        'user_id': user.id,
        'device_name': deviceName,
        'platform': platform,
        'os_version': osVersion,
        'app_version': appVersion,
        'is_current': true,
      });
    } catch (e) {
      // فشل تسجيل الجلسة لا يجب أن يوقف تسجيل الدخول
    }
  }

  /// يجلب كل جلسات الدخول الخاصة بالمستخدم الحالي، الأحدث أولاً
  static Future<List<LoginSessionInfo>> fetchSessions() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return [];

    final response = await SupabaseService.client
        .from('login_sessions')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => LoginSessionInfo.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// إنهاء جلسة معينة (حذفها من السجل)
  static Future<void> revokeSession(String sessionId) async {
    await SupabaseService.client
        .from('login_sessions')
        .delete()
        .eq('id', sessionId);
  }
}

class UserSettingsService {
  /// يجلب إعدادات المستخدم، وينشئها بقيم افتراضية لو غير موجودة
  static Future<Map<String, dynamic>> fetchOrCreateSettings() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      return {
        'two_factor_enabled': false,
        'notifications_enabled': true,
        'biometrics_enabled': false,
      };
    }

    final existing = await SupabaseService.client
        .from('user_settings')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing != null) return existing;

    final inserted = await SupabaseService.client
        .from('user_settings')
        .insert({'user_id': user.id})
        .select()
        .single();

    return inserted;
  }

  static Future<void> updateSetting(String key, bool value) async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return;

    await SupabaseService.client.from('user_settings').update({
      key: value,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', user.id);
  }
}

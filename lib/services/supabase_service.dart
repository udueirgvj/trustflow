import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// إعدادات الاتصال بـ Supabase الخاصة بمشروع TrustFlow
class SupabaseConfig {
  static const String url = 'https://tzefctcwgdpfrsaqyfxx.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6ZWZjdGN3Z2RwZnJzYXF5Znh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyMjQxMTQsImV4cCI6MjA5NzgwMDExNH0.OZczHhNCmotI2aDBb9tsB_TOlQmmiaoxBYkcND82N70';
}

class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// تسجيل الدخول بالبريد وكلمة المرور
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  /// إنشاء حساب جديد بالبريد وكلمة المرور مع تخزين البيانات في profiles
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    final userId = response.user?.id;
    if (userId != null) {
      try {
        final accountId = userId.replaceAll('-', '').substring(0, 8).toUpperCase();
        await client.from('profiles').upsert({
          'id': userId,
          'full_name': fullName,
          'email': email,
          'account_id': accountId,
        });
      } catch (_) {}
    }

    return response;
  }

  /// تسجيل الدخول عبر جوجل (Native Picker)
  static Future<AuthResponse> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId:
          '532770652661-dooldp2tg7ocve134e9v4li2h6r8rk83.apps.googleusercontent.com',
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('تم إلغاء تسجيل الدخول');

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) throw Exception('فشل الحصول على token من Google');

    return await client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  static Future<void> signOut() => client.auth.signOut();

  static Session? get currentSession => client.auth.currentSession;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}

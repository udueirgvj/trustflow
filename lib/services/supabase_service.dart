import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _channel = MethodChannel('com.example.trustflow/secrets');

  static Future<void> init() async {
    final url = await _channel.invokeMethod<String>('getUrl');
    final key = await _channel.invokeMethod<String>('getKey');

    await Supabase.initialize(
      url: url!,
      anonKey: key!,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

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
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}

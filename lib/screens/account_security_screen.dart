import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../services/session_service.dart';
import 'login_sessions_screen.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  bool _twoFactor = false;
  bool _loadingSettings = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await UserSettingsService.fetchOrCreateSettings();
      setState(() {
        _twoFactor = settings['two_factor_enabled'] as bool? ?? false;
        _loadingSettings = false;
      });
    } catch (e) {
      setState(() => _loadingSettings = false);
    }
  }

  Future<void> _toggleTwoFactor(bool value) async {
    setState(() => _twoFactor = value);
    try {
      await UserSettingsService.updateSetting('two_factor_enabled', value);
    } catch (e) {
      // رجوع القيمة لو فشل التحديث
      setState(() => _twoFactor = !value);
      _showSnack('فشل تحديث الإعداد، حاول مجدداً');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.bgCard),
    );
  }

  Future<void> _showChangeEmailDialog() async {
    final controller = TextEditingController(
      text: SupabaseService.client.auth.currentUser?.email ?? '',
    );
    final newEmail = await showDialog<String>(
      context: context,
      builder: (ctx) => _InputDialog(
        title: 'تغيير البريد الإلكتروني',
        hint: 'البريد الإلكتروني الجديد',
        controller: controller,
        keyboardType: TextInputType.emailAddress,
      ),
    );
    if (newEmail == null || newEmail.trim().isEmpty) return;

    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(email: newEmail.trim()),
      );
      _showSnack('تم إرسال رابط تأكيد إلى البريد الجديد');
    } catch (e) {
      _showSnack('فشل التغيير: ${e.toString()}');
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final controller = TextEditingController();
    final newPassword = await showDialog<String>(
      context: context,
      builder: (ctx) => _InputDialog(
        title: 'تغيير كلمة المرور',
        hint: 'كلمة المرور الجديدة (6 أحرف فأكثر)',
        controller: controller,
        obscure: true,
      ),
    );
    if (newPassword == null || newPassword.trim().length < 6) {
      if (newPassword != null) {
        _showSnack('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      }
      return;
    }

    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword.trim()),
      );
      _showSnack('تم تغيير كلمة المرور بنجاح');
    } catch (e) {
      _showSnack('فشل التغيير: ${e.toString()}');
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('حذف الحساب نهائياً',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'هذا الإجراء لا يمكن التراجع عنه. سيتم حذف جميع بياناتك بشكل نهائي.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    // حذف الحساب الفعلي يتطلب صلاحية service_role من جهة الخادم (Edge Function)
    // لأسباب أمنية لا يمكن تنفيذه مباشرة من تطبيق العميل بمفتاح anon.
    _showSnack('يرجى التواصل مع الدعم الفني لتأكيد حذف الحساب');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أمان الحساب')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined,
                  color: AppColors.blue, size: 40),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'أدوات التحكم الشاملة بحماية الحساب وتشفير البيانات. جميع التعديلات مدعومة بنظام التحقق ذي العاملين للحد من الاختراقات.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),

          _SectionHeader(title: 'بيانات الاتصال والتسجيل'),
          _SecurityCard(children: [
            _SecurityTile(
              icon: Icons.mail_outline,
              iconColor: AppColors.blue,
              title: 'تغيير البريد الإلكتروني',
              onTap: _showChangeEmailDialog,
            ),
            const _Divider(),
            _SecurityTile(
              icon: Icons.password_outlined,
              iconColor: AppColors.blue,
              title: 'تغيير كلمة المرور',
              onTap: _showChangePasswordDialog,
            ),
          ]),

          const SizedBox(height: 16),
          _SectionHeader(title: 'حماية إضافية'),
          _SecurityCard(children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  _loadingSettings
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : Switch(
                          value: _twoFactor,
                          onChanged: _toggleTwoFactor,
                          activeColor: AppColors.blue,
                        ),
                  const Spacer(),
                  const Text('التحقق بخطوتين (2FA)',
                      style: TextStyle(
                          color: AppColors.textPrimary, fontSize: 14)),
                  const SizedBox(width: 12),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.key_outlined,
                        color: AppColors.blue, size: 18),
                  ),
                ],
              ),
            ),
            const _Divider(),
            _SecurityTile(
              icon: Icons.access_time,
              iconColor: AppColors.blue,
              title: 'سجل نشاطات الدخول',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const LoginSessionsScreen()),
                );
              },
            ),
          ]),

          const SizedBox(height: 16),
          _SectionHeader(title: 'إدارة الحساب'),
          _SecurityCard(children: [
            _SecurityTile(
              icon: Icons.delete_outline,
              iconColor: AppColors.red,
              title: 'حذف الحساب نهائياً',
              titleColor: AppColors.red,
              onTap: _confirmDeleteAccount,
            ),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, right: 4),
      child: Text(title,
          style: const TextStyle(
              color: AppColors.textMuted, fontSize: 12, letterSpacing: 1)),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final List<Widget> children;
  const _SecurityCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Divider(color: Colors.white.withOpacity(0.08), height: 1);
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SecurityTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.chevron_left,
                color: AppColors.textMuted, size: 20),
            const Spacer(),
            Text(title,
                style: TextStyle(
                    color: titleColor ?? AppColors.textPrimary,
                    fontSize: 14)),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputDialog extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;

  const _InputDialog({
    required this.title,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textAlign: TextAlign.right,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.bgDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

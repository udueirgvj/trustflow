import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import 'account_security_screen.dart';
import 'edit_profile_screen.dart';
import 'notifications_settings_sheet.dart';
import 'theme_settings_sheet.dart';
import 'language_settings_sheet.dart';
import 'support_screen.dart';
import 'usage_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = 'مستخدم';
  String _accountId = '---';
  bool _loadingProfile = true;

  AppThemeMode _themeMode = AppThemeMode.system;
  String _languageCode = 'ar';
  String _languageLabel = 'العربية';

  String get _userEmail =>
      SupabaseService.client.auth.currentUser?.email ?? 'غير مسجل';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = SupabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _loadingProfile = false);
      return;
    }
    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select('full_name, account_id')
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _userName = (data['full_name'] as String?)?.isNotEmpty == true
              ? data['full_name'] as String
              : 'مستخدم';
          _accountId = (data['account_id'] as String?) ?? '---';
        });
      } else {
        final meta = SupabaseService.client.auth.currentUser?.userMetadata;
        final name = meta?['full_name'] as String?;
        if (name != null && name.isNotEmpty) {
          setState(() => _userName = name);
        }
        final rawId = userId.replaceAll('-', '').substring(0, 8).toUpperCase();
        setState(() => _accountId = rawId);
      }
    } catch (_) {
    } finally {
      setState(() => _loadingProfile = false);
    }
  }

  void _openNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationsSettingsSheet(
        onChanged: (values) {
          // TODO: حفظ التفضيلات بجدول user_settings عبر UserSettingsService
        },
      ),
    );
  }

  void _openThemeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ThemeSettingsSheet(
        current: _themeMode,
        onSelected: (mode) {
          setState(() => _themeMode = mode);
          Navigator.pop(context);
          // TODO: تطبيق المظهر فعلياً عبر MaterialApp themeMode
        },
      ),
    );
  }

  void _openLanguageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LanguageSettingsSheet(
        currentCode: _languageCode,
        onSelected: (lang) {
          setState(() {
            _languageCode = lang.code;
            _languageLabel = lang.label;
          });
          Navigator.pop(context);
          // TODO: تطبيق اللغة فعلياً عبر intl / easy_localization
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 20),

          _SectionHeader(title: 'الحساب'),
          _NavTile(
            icon: Icons.person_add_alt_outlined,
            iconColor: AppColors.blue,
            title: 'تعديل الملف الشخصي',
            subtitle: '',
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
              _loadProfile();
            },
          ),
          _NavTile(
            icon: Icons.shield_outlined,
            iconColor: AppColors.blue,
            title: 'أمان الحساب',
            subtitle: '',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const AccountSecurityScreen()),
              );
            },
          ),

          const SizedBox(height: 16),
          _SectionHeader(title: 'التفضيلات'),
          _NavTile(
            icon: Icons.notifications_outlined,
            iconColor: AppColors.blue,
            title: 'الإشعارات',
            subtitle: '',
            onTap: _openNotificationsSheet,
          ),
          _NavTile(
            icon: Icons.dark_mode_outlined,
            iconColor: AppColors.blue,
            title: 'المظهر',
            subtitle: '',
            onTap: _openThemeSheet,
          ),
          _NavTile(
            icon: Icons.translate,
            iconColor: AppColors.blue,
            title: 'اللغة',
            subtitle: _languageLabel,
            onTap: _openLanguageSheet,
          ),

          const SizedBox(height: 16),
          _SectionHeader(title: 'الدعم الفني والسياسات'),
          _NavTile(
            icon: Icons.help_outline,
            iconColor: AppColors.textSecondary,
            title: 'الدعم الفني',
            subtitle: '',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SupportScreen()),
              );
            },
          ),
          _NavTile(
            icon: Icons.description_outlined,
            iconColor: AppColors.textSecondary,
            title: 'سياسة الاستخدام',
            subtitle: '',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UsagePolicyScreen()),
              );
            },
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () async {
                await SupabaseService.signOut();
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.red, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout, color: AppColors.red, size: 18),
              label: const Text('تسجيل الخروج',
                  style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _loadingProfile
                    ? const SizedBox(
                        height: 40,
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2)))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_userName,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(_userEmail,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                        ],
                      ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.walletStart.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _userName.isNotEmpty ? _userName[0] : '?',
                  style: const TextStyle(
                      color: AppColors.walletStart,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _accountId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ المعرف')),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.walletStart.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('معرّف الحساب: $_accountId',
                      style: const TextStyle(
                          color: AppColors.walletStart,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  const SizedBox(width: 6),
                  const Icon(Icons.copy_rounded,
                      color: AppColors.walletStart, size: 14),
                ],
              ),
            ),
          ),
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

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.chevron_left,
                color: AppColors.textMuted, size: 20),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14)),
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

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppThemeMode { system, light, dark }

/// يستدعى بـ:
/// showModalBottomSheet(context: context, isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => ThemeSettingsSheet(
///     current: currentMode,
///     onSelected: (mode) { ... },
///   ));
class ThemeSettingsSheet extends StatelessWidget {
  final AppThemeMode current;
  final ValueChanged<AppThemeMode> onSelected;

  const ThemeSettingsSheet({
    super.key,
    required this.current,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Text(
              'المظهر',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            _ThemeOption(
              label: 'وضع النظام',
              icon: Icons.smartphone,
              selected: current == AppThemeMode.system,
              onTap: () => onSelected(AppThemeMode.system),
            ),
            const SizedBox(height: 10),
            _ThemeOption(
              label: 'الوضع الفاتح',
              icon: Icons.light_mode_outlined,
              selected: current == AppThemeMode.light,
              onTap: () => onSelected(AppThemeMode.light),
            ),
            const SizedBox(height: 10),
            _ThemeOption(
              label: 'الوضع الداكن',
              icon: Icons.dark_mode_outlined,
              selected: current == AppThemeMode.dark,
              onTap: () => onSelected(AppThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.blue
                : Colors.white.withOpacity(0.08),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.blue : AppColors.textSecondary,
                size: 18),
            const Spacer(),
            Text(label,
                style: TextStyle(
                  color: selected ? AppColors.blue : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                )),
            const SizedBox(width: 10),
            Icon(
              selected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.blue : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

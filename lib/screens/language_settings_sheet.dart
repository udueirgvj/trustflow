import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLanguage {
  final String code;
  final String label;
  const AppLanguage(this.code, this.label);
}

const List<AppLanguage> kSupportedLanguages = [
  AppLanguage('ar', 'العربية'),
  AppLanguage('en', 'English'),
  AppLanguage('fr', 'Français'),
  AppLanguage('es', 'Español'),
  AppLanguage('tr', 'Türkçe'),
];

/// يستدعى بـ:
/// showModalBottomSheet(context: context, isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => LanguageSettingsSheet(
///     currentCode: currentLangCode,
///     onSelected: (lang) { ... },
///   ));
class LanguageSettingsSheet extends StatelessWidget {
  final String currentCode;
  final ValueChanged<AppLanguage> onSelected;

  const LanguageSettingsSheet({
    super.key,
    required this.currentCode,
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
          mainAxisSize: MainAxisSize.min,
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
              'لغة التطبيق',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            ...kSupportedLanguages.map((lang) {
              final selected = lang.code == currentCode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSelected(lang),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
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
                        Text(lang.label,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.blue
                                  : AppColors.textPrimary,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            )),
                        const Spacer(),
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
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

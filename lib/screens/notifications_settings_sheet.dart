import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// يستدعى بـ:
/// showModalBottomSheet(context: context, isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => const NotificationsSettingsSheet());
class NotificationsSettingsSheet extends StatefulWidget {
  final bool initialSupport;
  final bool initialFunds;
  final bool initialRobotDeals;
  final ValueChanged<Map<String, bool>>? onChanged;

  const NotificationsSettingsSheet({
    super.key,
    this.initialSupport = true,
    this.initialFunds = true,
    this.initialRobotDeals = true,
    this.onChanged,
  });

  @override
  State<NotificationsSettingsSheet> createState() =>
      _NotificationsSettingsSheetState();
}

class _NotificationsSettingsSheetState
    extends State<NotificationsSettingsSheet> {
  late bool _support;
  late bool _funds;
  late bool _robotDeals;

  @override
  void initState() {
    super.initState();
    _support = widget.initialSupport;
    _funds = widget.initialFunds;
    _robotDeals = widget.initialRobotDeals;
  }

  void _emit() {
    widget.onChanged?.call({
      'support': _support,
      'funds': _funds,
      'robot_deals': _robotDeals,
    });
  }

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
              'إعدادات الإشعارات',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'اختر الإشعارات التي تود استلامها',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _NotificationOption(
              icon: Icons.headset_mic_outlined,
              iconColor: AppColors.blue,
              title: 'الدعم الفني',
              subtitle: 'تنبيهات عند وجود رد أو رسالة من الفريق',
              value: _support,
              onChanged: (v) {
                setState(() => _support = v);
                _emit();
              },
            ),
            const SizedBox(height: 10),
            _NotificationOption(
              icon: Icons.attach_money_rounded,
              iconColor: AppColors.green,
              title: 'استلام الأموال',
              subtitle: 'إشعارات فورية عند استلام أو تحويل رصيد',
              value: _funds,
              onChanged: (v) {
                setState(() => _funds = v);
                _emit();
              },
            ),
            const SizedBox(height: 10),
            _NotificationOption(
              icon: Icons.memory,
              iconColor: AppColors.orange,
              title: 'صفقات الروبوتات',
              subtitle: 'تنبيهات عند فتح أو إغلاق الصفقات الآلية',
              value: _robotDeals,
              onChanged: (v) {
                setState(() => _robotDeals = v);
                _emit();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }
}

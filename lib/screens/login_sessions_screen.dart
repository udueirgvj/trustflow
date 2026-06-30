import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/session_service.dart';

class LoginSessionsScreen extends StatefulWidget {
  const LoginSessionsScreen({super.key});

  @override
  State<LoginSessionsScreen> createState() => _LoginSessionsScreenState();
}

class _LoginSessionsScreenState extends State<LoginSessionsScreen> {
  List<LoginSessionInfo> _sessions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sessions = await SessionService.fetchSessions();
      setState(() {
        _sessions = sessions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل سجل الجلسات';
        _loading = false;
      });
    }
  }

  Future<void> _revoke(LoginSessionInfo session) async {
    try {
      await SessionService.revokeSession(session.id);
      setState(() => _sessions.removeWhere((s) => s.id == session.id));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إنهاء الجلسة')),
      );
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 30) return 'منذ ${diff.inDays} يوم';
    return '${dt.year}/${dt.month}/${dt.day}';
  }

  IconData _platformIcon(String platform) {
    switch (platform) {
      case 'Android':
        return Icons.android;
      case 'iOS':
        return Icons.phone_iphone;
      default:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل نشاطات الدخول')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(_error!,
                        style:
                            const TextStyle(color: AppColors.textSecondary)))
                : _sessions.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 80),
                          Center(
                            child: Text(
                              'لا يوجد سجل جلسات حتى الآن',
                              style: TextStyle(
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _sessions.length,
                        itemBuilder: (context, index) {
                          final session = _sessions[index];
                          return _SessionCard(
                            session: session,
                            timeLabel: _formatTime(session.createdAt),
                            icon: _platformIcon(session.platform),
                            onRevoke: session.isCurrent
                                ? null
                                : () => _revoke(session),
                          );
                        },
                      ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final LoginSessionInfo session;
  final String timeLabel;
  final IconData icon;
  final VoidCallback? onRevoke;

  const _SessionCard({
    required this.session,
    required this.timeLabel,
    required this.icon,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: session.isCurrent
            ? Border.all(color: AppColors.green.withOpacity(0.4))
            : null,
      ),
      child: Row(
        children: [
          if (onRevoke != null)
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.red, size: 20),
              onPressed: onRevoke,
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('الجلسة الحالية',
                  style: TextStyle(color: AppColors.green, fontSize: 11)),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(session.deviceName,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '${session.osVersion ?? session.platform} • $timeLabel',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.blue, size: 20),
          ),
        ],
      ),
    );
  }
}

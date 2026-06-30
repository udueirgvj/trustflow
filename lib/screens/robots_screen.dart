import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

class RobotsScreen extends StatefulWidget {
  final VoidCallback onGoToStore;
  const RobotsScreen({super.key, required this.onGoToStore});

  @override
  State<RobotsScreen> createState() => _RobotsScreenState();
}

class _RobotsScreenState extends State<RobotsScreen> {
  List<Map<String, dynamic>> _robots = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) { setState(() => _loading = false); return; }
      final data = await SupabaseService.client
          .from('purchases')
          .select()
          .eq('user_id', userId)
          .eq('status', 'approved')
          .order('created_at', ascending: false);
      setState(() { _robots = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        title: const Text('روبوتاتي', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: AppColors.textSecondary), onPressed: _load)],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _robots.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _robots.length,
                    itemBuilder: (_, i) => _RobotCard(robot: _robots[i]),
                  ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: const BoxDecoration(color: Color(0xFF1A2A3A), shape: BoxShape.circle),
                child: const Icon(Icons.smart_toy_outlined, color: Colors.cyan, size: 40),
              ),
              const SizedBox(height: 20),
              const Text('لا توجد روبوتات', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 10),
              const Text(
                'أنت لا تمتلك أي روبوتات فعّالة حالياً. يمكنك تصفح المتجر واختيار الروبوت المناسب لك للبدء بجني الأرباح آلياً.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onGoToStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('استكشاف المتجر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RobotCard extends StatefulWidget {
  final Map<String, dynamic> robot;
  const _RobotCard({required this.robot});

  @override
  State<_RobotCard> createState() => _RobotCardState();
}

class _RobotCardState extends State<_RobotCard> {
  bool _active = true;

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Center(child: Text('إعدادات ${widget.robot['robot_name']}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16))),
                const SizedBox(height: 20),
                _settingRow('الروبوت', widget.robot['robot_name'] ?? '---'),
                _settingRow('المبلغ المدفوع', '\$${widget.robot['amount']}'),
                _settingRow('طريقة الدفع', widget.robot['method'] ?? '---'),
                _settingRow('تاريخ الشراء', _formatDate(widget.robot['created_at'])),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () { setState(() => _active = !_active); Navigator.pop(context); },
                      icon: Icon(_active ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 18),
                      label: Text(_active ? 'إيقاف الروبوت' : 'تشغيل الروبوت', style: const TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _active ? AppColors.red : AppColors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '---';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) { return '---'; }
  }

  Widget _settingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showSettings,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _active ? Colors.cyan.withOpacity(0.3) : Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (_active ? Colors.green : Colors.grey).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_active ? 'يعمل الآن' : 'متوقف', style: TextStyle(color: _active ? Colors.green : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Text('\$${widget.robot['amount']}', style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 15)),
            ]),
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(widget.robot['robot_name'] ?? '---', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17)),
              const SizedBox(height: 4),
              Text('اضغط للتحكم', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 11)),
            ]),
            const SizedBox(width: 12),
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.cyan, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/wallet_model.dart';
import '../models/robot_model.dart';

class WalletService {
  static SupabaseClient get _db => SupabaseService.client;

  // ─── جلب بيانات المحفظة من profiles + بيانات حقيقية للروبوتات ────────────
  static Future<WalletModel> fetchWallet() async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) {
        debugPrint('[WalletService] uid is null — user not logged in');
        return WalletModel.zero();
      }
      debugPrint('[WalletService] fetching wallet for uid=$uid');

      // جلب كل الأعمدة الموجودة أولاً
      final row = await _db
          .from('profiles')
          .select('*')
          .eq('id', uid)
          .maybeSingle();

      debugPrint('[WalletService] raw row = $row');

      if (row == null) {
        // الصف غير موجود — أنشئه
        debugPrint('[WalletService] profile row missing — creating...');
        await _db.from('profiles').upsert({
          'id': uid,
          'balance': 0.0,
          'robot_profit': 0.0,
          'robot_capital': 0.0,
        });
      }

      // الرصيد العام للمحفظة
      final balance = row == null
          ? 0.0
          : (_toDouble(row['balance'])
              ?? _toDouble(row['wallet_balance'])
              ?? _toDouble(row['total_balance'])
              ?? 0.0);

      // ── رأس مال الروبوتات: مجموع سعر كل الروبوتات التي اشتراها المستخدم فعلياً ──
      double capital = 0.0;
      try {
        final purchases = await _db
            .from('purchases')
            .select('amount')
            .eq('user_id', uid)
            .eq('status', 'completed');
        for (final p in purchases) {
          capital += _toDouble(p['amount']) ?? 0.0;
        }
        debugPrint('[WalletService] robotCapital from purchases = $capital');
      } catch (e) {
        debugPrint('[WalletService] purchases table missing/error: $e — fallback to profiles.robot_capital');
        capital = row != null
            ? (_toDouble(row['robot_capital']) ?? _toDouble(row['capital']) ?? 0.0)
            : 0.0;
      }

      // ── أرباح الروبوتات: مجموع الأرباح اليومية المتراكمة من سجل profit_logs ──
      double profit = 0.0;
      try {
        final lastLog = await _db
            .from('profit_logs')
            .select('cumulative_profit')
            .eq('user_id', uid)
            .order('day_index', ascending: false)
            .limit(1)
            .maybeSingle();
        if (lastLog != null) {
          profit = _toDouble(lastLog['cumulative_profit']) ?? 0.0;
        } else if (row != null) {
          profit = _toDouble(row['robot_profit']) ?? _toDouble(row['profit']) ?? 0.0;
        }
        debugPrint('[WalletService] robotProfit = $profit');
      } catch (e) {
        debugPrint('[WalletService] profit_logs table missing/error: $e — fallback to profiles.robot_profit');
        profit = row != null
            ? (_toDouble(row['robot_profit']) ?? _toDouble(row['profit']) ?? 0.0)
            : 0.0;
      }

      return WalletModel(
        totalBalance: balance,
        robotProfit:  profit,
        robotCapital: capital,
        isInsured:    true,
      );
    } catch (e, st) {
      debugPrint('[WalletService] fetchWallet ERROR: $e\n$st');
      return WalletModel.zero();
    }
  }

  // ─── جلب أداء الروبوتات + بيانات الرسم البياني ───────────────────────────
  static Future<RobotPerformanceModel> fetchRobotPerformance() async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) return RobotPerformanceModel.empty();

      // ── الروبوتات النشطة ────────────────────────────────────────────────
      List robots = [];
      try {
        robots = await _db
            .from('user_robots')
            .select('id, daily_profit, capital')
            .eq('user_id', uid)
            .eq('is_active', true);
        debugPrint('[WalletService] active robots = ${robots.length}');
      } catch (e) {
        debugPrint('[WalletService] user_robots table missing or error: $e');
      }

      final activeCount = robots.length;
      double totalCapital = 0;
      for (final r in robots) {
        totalCapital += _toDouble(r['capital']) ?? 0.0;
      }

      // ── سجل الأرباح للرسم البياني ──────────────────────────────────────
      List logs = [];
      try {
        logs = await _db
            .from('profit_logs')
            .select('day_index, cumulative_profit')
            .eq('user_id', uid)
            .order('day_index', ascending: true)
            .limit(14);
        debugPrint('[WalletService] profit_logs count = ${logs.length}');
      } catch (e) {
        debugPrint('[WalletService] profit_logs table missing or error: $e');
      }

      List<ChartPoint> chartData;
      if (logs.isEmpty) {
        chartData = [ChartPoint(x: 0, y: 0), ChartPoint(x: 1, y: 0)];
      } else {
        chartData = logs.asMap().entries.map((e) {
          final val = _toDouble(e.value['cumulative_profit']) ?? 0.0;
          return ChartPoint(x: e.key.toDouble(), y: val <= 0 ? 0.001 : val);
        }).toList();
      }

      final totalDays  = logs.length;
      final profitDays = logs
          .where((l) => (_toDouble(l['cumulative_profit']) ?? 0) > 0)
          .length;
      final successRate = totalDays == 0
          ? 0.0
          : (profitDays / totalDays) * 100.0;

      return RobotPerformanceModel(
        activeRobots: activeCount,
        tradeVolume:  totalCapital,
        successRate:  successRate,
        chartData:    chartData,
      );
    } catch (e, st) {
      debugPrint('[WalletService] fetchRobotPerformance ERROR: $e\n$st');
      return RobotPerformanceModel.empty();
    }
  }

  // ─── مساعد: تحويل أي قيمة إلى double بأمان ──────────────────────────────
  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

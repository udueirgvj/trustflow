import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/wallet_model.dart';
import '../models/robot_model.dart';

class WalletService {
  static SupabaseClient get _db => SupabaseService.client;

  static Future<WalletModel> fetchWallet() async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) return WalletModel.zero();

      final walletRow = await _db
          .from('wallets')
          .select('*')
          .eq('user_id', uid)
          .maybeSingle();

      final balance = walletRow == null
          ? 0.0
          : (_toDouble(walletRow['balance']) ?? 0.0);

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
      } catch (e) {
        capital = walletRow != null
            ? (_toDouble(walletRow['robot_capital']) ?? 0.0)
            : 0.0;
      }

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
        } else if (walletRow != null) {
          profit = _toDouble(walletRow['robot_profit']) ?? 0.0;
        }
      } catch (e) {
        profit = walletRow != null
            ? (_toDouble(walletRow['robot_profit']) ?? 0.0)
            : 0.0;
      }

      return WalletModel(
        totalBalance: balance,
        robotProfit: profit,
        robotCapital: capital,
        isInsured: true,
      );
    } catch (e, st) {
      debugPrint('[WalletService] fetchWallet ERROR: $e\n$st');
      return WalletModel.zero();
    }
  }

  static Future<RobotPerformanceModel> fetchRobotPerformance() async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) return RobotPerformanceModel.empty();

      List robots = [];
      try {
        robots = await _db
            .from('user_robots')
            .select('id, daily_profit, capital')
            .eq('user_id', uid)
            .eq('is_active', true);
      } catch (e) {
        debugPrint('[WalletService] user_robots error: $e');
      }

      final activeCount = robots.length;
      double totalCapital = 0;
      for (final r in robots) {
        totalCapital += _toDouble(r['capital']) ?? 0.0;
      }

      List logs = [];
      try {
        logs = await _db
            .from('profit_logs')
            .select('day_index, cumulative_profit')
            .eq('user_id', uid)
            .order('day_index', ascending: true)
            .limit(14);
      } catch (e) {
        debugPrint('[WalletService] profit_logs error: $e');
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

      final totalDays = logs.length;
      final profitDays = logs
          .where((l) => (_toDouble(l['cumulative_profit']) ?? 0) > 0)
          .length;
      final successRate =
          totalDays == 0 ? 0.0 : (profitDays / totalDays) * 100.0;

      return RobotPerformanceModel(
        activeRobots: activeCount,
        tradeVolume: totalCapital,
        successRate: successRate,
        chartData: chartData,
      );
    } catch (e, st) {
      debugPrint('[WalletService] fetchRobotPerformance ERROR: $e\n$st');
      return RobotPerformanceModel.empty();
    }
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

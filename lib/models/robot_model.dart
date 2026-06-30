class RobotPerformanceModel {
  final int activeRobots;
  final double tradeVolume;
  final double successRate;
  final List<ChartPoint> chartData;

  RobotPerformanceModel({
    required this.activeRobots,
    required this.tradeVolume,
    required this.successRate,
    required this.chartData,
  });

  factory RobotPerformanceModel.empty() => RobotPerformanceModel(
        activeRobots: 0,
        tradeVolume: 0,
        successRate: 0,
        chartData: [ChartPoint(x: 0, y: 0), ChartPoint(x: 1, y: 0)],
      );
}

class ChartPoint {
  final double x;
  final double y;
  ChartPoint({required this.x, required this.y});
}

// بيانات مؤقتة للمعاينة فقط — تُستبدل بالبيانات الحقيقية من Supabase
final sampleRobotData = RobotPerformanceModel(
  activeRobots: 3,
  tradeVolume: 3.0,
  successRate: 100.0,
  chartData: [
    ChartPoint(x: 0, y: 0.2),
    ChartPoint(x: 1, y: 0.4),
    ChartPoint(x: 2, y: 0.6),
    ChartPoint(x: 3, y: 0.8),
    ChartPoint(x: 4, y: 1.2),
    ChartPoint(x: 5, y: 1.5),
    ChartPoint(x: 6, y: 2.0),
    ChartPoint(x: 7, y: 2.4),
    ChartPoint(x: 8, y: 2.6),
    ChartPoint(x: 9, y: 2.7),
    ChartPoint(x: 10, y: 2.8),
    ChartPoint(x: 11, y: 2.85),
  ],
);

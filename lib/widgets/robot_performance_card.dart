import 'package:flutter/material.dart';
import '../models/robot_model.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class RobotPerformanceCard extends StatelessWidget {
  final RobotPerformanceModel data;
  const RobotPerformanceCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── الهيدر ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  // أيقونة الرسم البياني
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.bgCardLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.show_chart,
                        color: AppColors.walletStart, size: 18),
                  ),
                  const SizedBox(width: 8),
                  // شارة الروبوتات النشطة
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${data.activeRobots} روبوتات نشطة',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                  ),
                ]),
                const Text('أداء الروبوتات الحي',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
              ],
            ),

            const SizedBox(height: 18),

            // ── الرسم البياني ─────────────────────────────────────────
            SizedBox(
              height: 130,
              child: CustomPaint(
                painter: _ChartPainter(points: data.chartData),
                size: Size.infinite,
              ),
            ),

            const SizedBox(height: 18),

            // ── إحصائيات ─────────────────────────────────────────────
            Row(children: [
              // معدل النجاح
              Expanded(
                child: _StatTile(
                  icon: Icons.trending_up,
                  iconColor: AppColors.green,
                  label: 'معدل النجاح',
                  value: '${data.successRate.toStringAsFixed(1)}%',
                ),
              ),
              const SizedBox(width: 12),
              // حجم التداول
              Expanded(
                child: _StatTile(
                  icon: Icons.monetization_on_outlined,
                  iconColor: AppColors.orange,
                  label: 'حجم التداول',
                  value: '\$${data.tradeVolume.toStringAsFixed(0)}',
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(label,
              style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
          ]),
          Icon(icon, color: iconColor, size: 22),
        ],
      ),
    );
  }
}

// ── الرسم البياني ─────────────────────────────────────────────────────────────
class _ChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  _ChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // ── يحدّد لون الخط حسب اتجاه الأداء الحقيقي: أخضر صاعد = ربح، أحمر هابط = خسارة ──
    final isRising = points.last.y >= points.first.y;
    final lineColor = isRising ? AppColors.green : AppColors.red;

    final maxY = points.map((p) => p.y).reduce(max);
    final minYRaw = points.map((p) => p.y).reduce(min);
    final minY = minYRaw < 0 ? minYRaw : 0.0;
    final maxX = points.map((p) => p.x).reduce(max);
    final rangeY = maxY - minY;

    List<Offset> offsets = points.map((p) {
      double dx = maxX == 0 ? 0 : (p.x / maxX) * size.width;
      double dy = rangeY == 0
          ? size.height
          : size.height - ((p.y - minY) / rangeY) * (size.height * 0.85);
      return Offset(dx, dy);
    }).toList();

    // ── خلفية متدرجة ──────────────────────────────────────────────────────
    final fillPath = Path()
      ..moveTo(offsets.first.dx, size.height)
      ..addPolygon(offsets, false)
      ..lineTo(offsets.last.dx, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            lineColor.withOpacity(0.35),
            lineColor.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // ── الخط المنحني ──────────────────────────────────────────────────────
    final linePath = Path()
      ..moveTo(offsets.first.dx, offsets.first.dy);

    for (int i = 1; i < offsets.length; i++) {
      final prev = offsets[i - 1];
      final curr = offsets[i];
      final cp1 = Offset((prev.dx + curr.dx) / 2, prev.dy);
      final cp2 = Offset((prev.dx + curr.dx) / 2, curr.dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // ── خطوط الشبكة ──────────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (1 - i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ── تسميات المحور ────────────────────────────────────────────────────
    void drawLabel(String text, Offset pos) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.4), fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos);
    }

    drawLabel(maxY.toStringAsFixed(0), const Offset(4, 0));
    drawLabel('0', Offset(4, size.height - 14));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

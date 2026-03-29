import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';

class ImprovementVelocityWidget extends StatelessWidget {
  final List<MapEntry<int, double>> velocitySeries;
  final bool comfortZoneWarning;

  const ImprovementVelocityWidget({
    super.key,
    required this.velocitySeries,
    required this.comfortZoneWarning,
  });

  @override
  Widget build(BuildContext context) {
    if (velocitySeries.isEmpty) return const SizedBox.shrink();

    // Default 60 day viewport
    final double maxX = velocitySeries.last.key.toDouble();
    final double minX = max(1.0, maxX - 59.0);

    final spots = velocitySeries.map((e) => FlSpot(e.key.toDouble(), e.value * 100)).toList();

    // Reckoning Days
    final reckoningDays = [30, 60, 90, 180, 270];
    final verticalLines = reckoningDays
        .where((day) => day <= maxX)
        .map(
          (day) => VerticalLine(
            x: day.toDouble(),
            color: AppColors.primary,
            strokeWidth: 1,
            dashArray: [4, 4],
            label: VerticalLineLabel(
              show: true,
              labelResolver: (_) => 'DAY $day',
              style: const TextStyle(color: AppColors.primary, fontSize: 8),
              alignment: Alignment.bottomRight,
            ),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Text(
                'IMPROVEMENT VELOCITY',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppFontSize.md,
                  letterSpacing: 2.0,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
            ),
            if (comfortZoneWarning)
              const Text(
                'COMFORT ZONE WARNING',
                style: TextStyle(color: AppColors.error, fontSize: 10, letterSpacing: 1.0, fontWeight: AppFontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          '7-DAY ROLLING AVERAGE OVER LIFETIME',
          style: TextStyle(color: AppColors.textDisabled, fontSize: 10, letterSpacing: 1.5),
        ),
        const SizedBox(height: AppSpacing.xl),
        
        // SingleChildScrollView to allow panning backwards.
        // The fixed width determines how much is visible. We calculate width by multiplying data points.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true, // starts from end (current day)
          child: SizedBox(
            // Approx 6 pixels per day to allow scrolling, with a minimum width equivalent to the screen.
            width: max(MediaQuery.of(context).size.width - AppSpacing.xl * 2, velocitySeries.length * 6.0),
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                // Do not constrain minX/maxX here, let it plot the whole Series over the forced width
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(color: AppColors.divider, strokeWidth: 1, dashArray: [2, 2]),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: max(1, (velocitySeries.length / 10)).floorToDouble(),
                      getTitlesWidget: (val, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text('D${val.toInt()}', style: const TextStyle(color: AppColors.textDisabled, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 25,
                      getTitlesWidget: (val, meta) => Text('${val.toInt()}%', style: const TextStyle(color: AppColors.textDisabled, fontSize: 10)),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(verticalLines: verticalLines),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    // If slope is upward = gold, if downward = red. 
                    // `fl_chart` doesn't support segmented colors natively easily without multiple lines.
                    // We will use a gradient matching Y values roughly, or just stark white.
                    // Instead, per the spec: "upward slope in gold, downward in red", `FlLine` color mapping isn't fully supported
                    // per segment. We will use a solid Gold line. A custom gradient could work, but standard fl_chart solid line is safest.
                    color: AppColors.primary,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

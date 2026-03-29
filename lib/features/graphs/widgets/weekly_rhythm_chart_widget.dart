import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';

class WeeklyRhythmChartWidget extends StatelessWidget {
  final Map<int, double> weekdayAverages;
  final int weakestWeekday;

  const WeeklyRhythmChartWidget({
    super.key,
    required this.weekdayAverages,
    required this.weakestWeekday,
  });

  @override
  Widget build(BuildContext context) {
    if (weekdayAverages.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 1; i <= 7; i++) {
      spots.add(FlSpot(i.toDouble(), (weekdayAverages[i] ?? 0.0) * 100)); // 0-100 scale
    }

    // Identify weak spot for UI tooltip styling
    final weakDayName = _weekdayString(weakestWeekday);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'WEEKLY RHYTHM',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppFontSize.md,
                  letterSpacing: 2.0,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'YOUR WEAKEST DAY',
                  style: TextStyle(color: AppColors.error, fontSize: 10, letterSpacing: 1.0, fontWeight: AppFontWeight.bold),
                ),
                Text(
                  weakDayName.toUpperCase(),
                  style: const TextStyle(color: AppColors.error, fontSize: AppFontSize.md, letterSpacing: 2.0, fontWeight: AppFontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              minX: 1,
              maxX: 7,
              minY: 0,
              maxY: 100,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (val, meta) {
                      final style = TextStyle(
                        color: val.toInt() == weakestWeekday ? AppColors.error : AppColors.textDisabled,
                        fontWeight: val.toInt() == weakestWeekday ? AppFontWeight.bold : AppFontWeight.regular,
                        fontSize: 10,
                      );
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(_weekdayString(val.toInt()), style: style),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.textSecondary,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      if (spot.x.toInt() == weakestWeekday) {
                        return FlDotCirclePainter(radius: 4, color: AppColors.error, strokeColor: Colors.transparent);
                      }
                      return FlDotCirclePainter(radius: 3, color: AppColors.primary, strokeColor: Colors.transparent);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _weekdayString(int day) {
    switch (day) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}

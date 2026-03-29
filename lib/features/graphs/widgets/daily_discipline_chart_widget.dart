import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/models.dart';

class DailyDisciplineChartWidget extends StatelessWidget {
  final List<DayRecordModel> last30Days;
  final double personalLifetimeAverage;

  const DailyDisciplineChartWidget({
    super.key,
    required this.last30Days,
    required this.personalLifetimeAverage,
  });

  @override
  Widget build(BuildContext context) {
    if (last30Days.isEmpty) return const SizedBox.shrink();

    // BarGroups
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < last30Days.length; i++) {
      final r = last30Days[i];
      final isFail = r.overallCompletionRate < 0.5;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: r.overallCompletionRate * 100, // scaled 0-100
              color: isFail ? AppColors.error : AppColors.primary,
              width: 8,
              borderRadius: BorderRadius.zero,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'DAILY DISCIPLINE (LAST 30 DAYS)',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: AppFontSize.md,
            letterSpacing: 2.0,
            fontWeight: AppFontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: 100,
              minY: 0,
              barGroups: barGroups,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.divider,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 25,
                    getTitlesWidget: (value, meta) {
                      return Text('${value.toInt()}%', style: const TextStyle(color: AppColors.textDisabled, fontSize: 10));
                    },
                  ),
                ),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: personalLifetimeAverage * 100,
                    color: AppColors.primary.withOpacity(0.5),
                    strokeWidth: 2,
                    dashArray: [2, 2],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: const TextStyle(color: AppColors.primary, fontSize: 10),
                      labelResolver: (line) => 'AVG',
                    ),
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

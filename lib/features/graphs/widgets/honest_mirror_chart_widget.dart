import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/models.dart';

class HonestMirrorChartWidget extends StatefulWidget {
  final List<DayRecordModel> records;
  final bool flashMirror;
  final VoidCallback onFlashComplete;

  const HonestMirrorChartWidget({
    super.key,
    required this.records,
    required this.flashMirror,
    required this.onFlashComplete,
  });

  @override
  State<HonestMirrorChartWidget> createState() => _HonestMirrorChartWidgetState();
}

class _HonestMirrorChartWidgetState extends State<HonestMirrorChartWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  late final Animation<double> _pulse = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
  ]).animate(_ctrl);

  @override
  void initState() {
    super.initState();
    if (widget.flashMirror) {
      _ctrl.forward().then((_) {
        widget.onFlashComplete();
      });
    }
  }

  @override
  void didUpdateWidget(covariant HonestMirrorChartWidget oldWidget) {
    if (widget.flashMirror && !oldWidget.flashMirror) {
      _ctrl.forward(from: 0).then((_) {
        widget.onFlashComplete();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.records.isEmpty) return const SizedBox.shrink();

    // Map the spots for Actual (White) and Target (Gold, always 100)
    final actualSpots = <FlSpot>[];
    final targetSpots = <FlSpot>[];
    
    for (int i = 0; i < widget.records.length; i++) {
      final r = widget.records[i];
      final x = r.journeyDay.toDouble();
      actualSpots.add(FlSpot(x, r.overallCompletionRate * 100));
      targetSpots.add(FlSpot(x, 100)); // Target always 100%
    }

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Color.lerp(Colors.transparent, AppColors.primary, _pulse.value)!,
              width: 2,
            ),
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'THE HONEST MIRROR',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: AppFontSize.md,
              letterSpacing: 2.0,
              fontWeight: AppFontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'THE GAP IS YOUR SELF-DECEPTION',
            style: TextStyle(color: AppColors.error, fontSize: 10, letterSpacing: 1.5, fontWeight: AppFontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 110,
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
                      interval: 7, 
                      getTitlesWidget: (val, meta) => SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text('D${val.toInt()}', style: const TextStyle(color: AppColors.textDisabled, fontSize: 10)),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 50,
                      getTitlesWidget: (val, meta) => Text('${val.toInt()}%', style: const TextStyle(color: AppColors.textDisabled, fontSize: 10)),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: targetSpots,
                    isCurved: false,
                    color: AppColors.primary,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dashArray: [10, 5],
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: actualSpots,
                    isCurved: true,
                    color: AppColors.textPrimary, // white solid
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/graphs_bloc.dart';

class GoalBreakdownListWidget extends StatelessWidget {
  final List<GoalGraphData> goalBreakdowns;

  const GoalBreakdownListWidget({super.key, required this.goalBreakdowns});

  @override
  Widget build(BuildContext context) {
    if (goalBreakdowns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'GOAL-BY-GOAL BREAKDOWN',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: AppFontSize.md,
            letterSpacing: 2.0,
            fontWeight: AppFontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        SizedBox(
          height: 120, // fixed height for horizontal scroll
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: goalBreakdowns.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final g = goalBreakdowns[index];
              return Container(
                width: 240, // 8 * 30 days
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      g.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.primary, fontWeight: AppFontWeight.bold, fontSize: AppFontSize.sm, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('LIFETIME: ${(g.lifetimeCompletionRate * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.textDisabled, fontSize: 10)),
                        Text('STREAK: ${g.currentStreak} (MAX ${g.longestStreak})', style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: AppFontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    
                    // 30 day sparkline
                    _BooleanSparkline(data: g.sparkline30Days),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BooleanSparkline extends StatelessWidget {
  final List<double> data; // 1.0 or 0.0
  const _BooleanSparkline({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox(height: 10);
    return SizedBox(
      height: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(data.length, (i) {
          final isSuccess = data[i] == 1.0;
          return Container(
            width: 5,
            height: 10,
            margin: const EdgeInsets.only(left: 2),
            color: isSuccess ? AppColors.primary : AppColors.surface,
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/models.dart';
import '../bloc/goals_state.dart';

class GoalCard extends StatelessWidget {
  final GoalCardData data;

  const GoalCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.goal.title.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppFontSize.md,
                    fontWeight: AppFontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'DAY ${data.goal.addedOnDay}',
                style: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: AppFontSize.xs,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.goal.targetValue.toUpperCase(),
            style: const TextStyle(color: AppColors.primary, fontSize: AppFontSize.sm),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Stats string
          Text(
            'COMPLETED ${data.totalCompleted} OF ${data.totalDaysActive} DAYS — ${(data.completionRate * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: AppFontSize.xs, letterSpacing: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Visualization
          _buildVisualization(),
        ],
      ),
    );
  }

  Widget _buildVisualization() {
    switch (data.goal.category) {
      case GoalCategory.daily:
        return _DailySparkline(sparkline: data.last14DaysSparkline);
      case GoalCategory.monthly:
        return _MonthlyGrid(grid: data.currentMonthGrid);
      case GoalCategory.yearly:
        return _YearlyBlocks(blocks: data.yearlyBlocks);
    }
  }
}

class _DailySparkline extends StatelessWidget {
  final List<bool> sparkline;
  const _DailySparkline({required this.sparkline});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(sparkline.length, (i) {
          final isCompleted = sparkline[i];
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: isCompleted ? Colors.transparent : AppColors.divider,
                width: 1,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MonthlyGrid extends StatelessWidget {
  final List<bool> grid;
  const _MonthlyGrid({required this.grid});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(grid.length < 30 ? 30 : grid.length, (i) {
        if (i >= grid.length) {
          return _buildSquare(AppColors.surface, AppColors.divider); // Future
        }
        final isCompleted = grid[i];
        return _buildSquare(
          isCompleted ? AppColors.primary : AppColors.surface,
          isCompleted ? Colors.transparent : AppColors.error,
        );
      }),
    );
  }

  Widget _buildSquare(Color fill, Color border) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border, width: 1),
      ),
    );
  }
}

class _YearlyBlocks extends StatelessWidget {
  final List<int> blocks;
  const _YearlyBlocks({required this.blocks});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(12, (i) {
        final val = i < blocks.length ? blocks[i] : 0;
        Color fill;
        Color border = Colors.transparent;
        switch (val) {
          case 3: // Gold
            fill = AppColors.primary;
            break;
          case 2: // Yellow
            fill = Colors.yellow.shade700;
            break;
          case 1: // Red
            fill = AppColors.error;
            border = AppColors.error;
            break;
          case 0: // Grey/Future
          default:
            fill = AppColors.surface;
            border = AppColors.divider;
            break;
        }
        
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: border, width: 1),
          ),
        );
      }),
    );
  }
}

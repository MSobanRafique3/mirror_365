import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/dedication_ring.dart';
import '../widgets/shadow_stats_widget.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/models.dart';
import '../../goals/widgets/add_goal_bottom_sheet.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (p, c) => p.isLoading != c.isLoading || p.showMirrorScreen != c.showMirrorScreen,
      builder: (context, state) {
        if (state.isLoading || state.showMirrorScreen) return const SizedBox.shrink();

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddGoalBottomSheet(context),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: AppColors.background),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
                  SliverToBoxAdapter(
                    child: _TopHeader(
                      day: state.timeSnapshot?.journeyDay ?? 1,
                      remaining: state.timeSnapshot?.daysRemaining ?? 365,
                      score: state.overallScore,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
                  
                  // Cost Counter Banner
                  SliverToBoxAdapter(
                    child: _CostCounter(totalFailedDays: state.last7DaysRecords.where((r) => r.isFailed).length),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

                  // Dedication Ring
                  SliverToBoxAdapter(
                    child: Center(
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: DedicationRing(
                          dailyScore: state.dailyArcScore,
                          monthlyScore: state.monthlyArcScore,
                          yearlyScore: state.yearlyArcScore,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

                  // Shadow Stats Dropdown
                  const SliverToBoxAdapter(
                    child: ShadowStatsWidget(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                  // Check-In window status
                  if (!state.isCheckInWindowOpen)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Text(
                          'CHECK-IN WINDOW CLOSED.\nRETURNS IN THE LAST 6 HOURS OF THE DAY.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: AppFontSize.xs,
                            fontWeight: AppFontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(
                    child: Text(
                      'DAILY GOALS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppFontSize.md,
                        letterSpacing: 2.0,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final goal = state.todaysGoals[index];
                        final entry = state.todaysEntries.cast<GoalEntryModel?>().firstWhere(
                          (e) => e != null && e.goalId == goal.goalId, 
                          orElse: () => null,
                        );
                        final isCompleted = entry?.isCompleted ?? false;
                        
                        return _GoalTile(
                          goal: goal,
                          isCompleted: isCompleted,
                          completionMs: entry?.completedAt,
                          isEnabled: state.isCheckInWindowOpen,
                          onToggle: () => context.read<DashboardBloc>().add(DashboardDailyGoalToggled(goal.goalId)),
                        );
                      },
                      childCount: state.todaysGoals.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddGoalBottomSheet(BuildContext context) {
    // We'll implement this AddGoalBottomSheet separately and show it here.
    // Ensure we provide the existing bloc to the modal since it creates a new context route.
    final bloc = context.read<DashboardBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: const AddGoalBottomSheet(),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final int day;
  final int remaining;
  final double score;

  const _TopHeader({
    required this.day, required this.remaining, required this.score
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DAY $day',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: AppFontWeight.extraBold,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              '$remaining DAYS REMAINING',
              style: const TextStyle(
                color: AppColors.textDisabled,
                fontSize: AppFontSize.xs,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(score * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 28,
                fontWeight: AppFontWeight.extraBold,
                letterSpacing: -0.5,
              ),
            ),
            const Text(
              'DISCIPLINE',
              style: TextStyle(
                color: AppColors.textDisabled,
                fontSize: AppFontSize.xs,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CostCounter extends StatelessWidget {
  final int totalFailedDays;
  const _CostCounter({required this.totalFailedDays});

  @override
  Widget build(BuildContext context) {
    if (totalFailedDays == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.error),
      ),
      child: Text(
        'YOU HAVE FAILED $totalFailedDays DAYS RECENTLY. MOMENTS YOU CHOSE COMFORT.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.error,
          fontSize: AppFontSize.sm,
          fontWeight: AppFontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final JourneyGoalModel goal;
  final bool isCompleted;
  final int? completionMs;
  final bool isEnabled;
  final VoidCallback onToggle;

  const _GoalTile({
    required this.goal,
    required this.isCompleted,
    this.completionMs,
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final formatTime = completionMs != null && completionMs! > 0 
      ? DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(completionMs!)) 
      : '';

    return GestureDetector(
      onTap: isEnabled ? onToggle : null,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
            color: isCompleted ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : Colors.transparent,
                border: Border.all(color: AppColors.primary),
              ),
              child: isCompleted 
                ? const Icon(Icons.check, size: 18, color: AppColors.background)
                : const SizedBox.shrink(),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: TextStyle(
                      color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      fontSize: AppFontSize.md,
                    ),
                  ),
                  if (goal.targetValue.isNotEmpty)
                    Text(
                      goal.targetValue,
                      style: const TextStyle(color: AppColors.textDisabled, fontSize: AppFontSize.xs),
                    ),
                ],
              ),
            ),
            if (isCompleted && formatTime.isNotEmpty)
              Text(
                formatTime,
                style: const TextStyle(color: AppColors.primary, fontSize: AppFontSize.xs),
              ),
          ],
        ),
      ),
    );
  }
}

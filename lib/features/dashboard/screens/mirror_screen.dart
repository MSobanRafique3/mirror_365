import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/day_square.dart';
import '../../../core/constants/app_constants.dart';

class MirrorScreen extends StatelessWidget {
  const MirrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (p, c) => p.showMirrorScreen != c.showMirrorScreen || p.isLoading != c.isLoading,
      builder: (context, state) {
        if (!state.showMirrorScreen || state.isLoading) {
          return const SizedBox.shrink();
        }

        final scoreText = '${(state.overallScore * 100).toStringAsFixed(0)}%';
        final remaining = state.timeSnapshot?.daysRemaining ?? 365;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // The Wall Notification
                  if (state.isDropWarningActive) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.error, width: 2),
                      ),
                      child: const Text(
                        'YOU ARE BLEEDING.\n3 DAYS TO CORRECT.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: AppFontSize.md,
                          fontWeight: AppFontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ] else if (state.isWallDay) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: const Text(
                        'MOST PEOPLE QUIT HERE.\nYOU ARE STILL HERE.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: AppFontSize.md,
                          fontWeight: AppFontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  Text(
                    'DAY ${state.timeSnapshot?.journeyDay ?? 1}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 48,
                      fontWeight: AppFontWeight.extraBold,
                      letterSpacing: -1.0,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$remaining DAYS REMAINING',
                    style: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: AppFontSize.md,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'YOUR SCORE: $scoreText',
                    style: TextStyle(
                      color: state.overallScoreIsImproving 
                        ? AppColors.primary 
                        : AppColors.textSecondary,
                      fontSize: AppFontSize.lg,
                      fontWeight: AppFontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Level Name
                  if (state.currentLevel != null)
                    Text(
                      'LEVEL ${state.currentLevel!.currentLevel} — ${state.currentLevel!.levelName.toUpperCase()}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppFontSize.sm,
                        letterSpacing: 1.5,
                      ),
                    ),

                  const SizedBox(height: AppSpacing.md),
                  
                  // 7 Days
                  Row(
                    children: state.last7DaysRecords
                        .map((r) => DaySquare(record: r))
                        .toList(),
                  ),

                  const Spacer(),

                  // Weekly Report generated from worst goals
                  if (state.weeklyReportText != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.error),
                        color: AppColors.error.withValues(alpha: 0.05),
                      ),
                      child: Text(
                        state.weeklyReportText!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: AppFontSize.md,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Face Today Button
                  GestureDetector(
                    onTap: () => context
                        .read<DashboardBloc>()
                        .add(const DashboardFaceTodayClicked()),
                    child: Container(
                      width: double.infinity,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        border: Border.all(color: AppColors.primary),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'FACE TODAY',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: AppFontSize.lg,
                          fontWeight: AppFontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

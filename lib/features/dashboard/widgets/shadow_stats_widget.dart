import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/goal_entry_repository.dart';

class ShadowStatsWidget extends StatelessWidget {
  const ShadowStatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      // Only rebuild if these specific score/time variables change
      buildWhen: (p, c) => p.overallScore != c.overallScore || p.timeSnapshot != c.timeSnapshot,
      builder: (context, state) {
        if (state.timeSnapshot == null) return const SizedBox.shrink();

        final actualScore = state.overallScore;
        final actualScorePercent = (actualScore * 100).toStringAsFixed(1);
        final gapPercent = ((1.0 - actualScore) * 100).toStringAsFixed(1);

        final entryRepo = getIt<GoalEntryRepository>();
        final currentDay = state.timeSnapshot!.journeyDay;
        // Check comfort by looking at all past entries
        final allEntries = entryRepo.getAllEntries();
        int comfortChoices = 0;
        for (final entry in allEntries) {
          if (entry.journeyDay < currentDay && !entry.isCompleted) {
            comfortChoices++;
          }
        }

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
            iconColor: AppColors.textDisabled,
            collapsedIconColor: AppColors.textDisabled,
            title: const Text(
              'SHADOW STATS',
              style: TextStyle(
                color: AppColors.textDisabled,
                fontSize: AppFontSize.md, // not using uppercase specifically applied here to keep pure theme
                letterSpacing: 2.0,
                fontWeight: AppFontWeight.bold,
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'If you had completed every goal, your score would be 100%.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: AppFontSize.sm, height: 1.5),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: AppFontSize.sm, height: 1.5),
                        children: [
                          const TextSpan(text: 'Your actual score: '),
                          TextSpan(text: '$actualScorePercent%', style: const TextStyle(color: AppColors.primary, fontWeight: AppFontWeight.bold)),
                          const TextSpan(text: '. The gap: '),
                          TextSpan(text: '$gapPercent%', style: const TextStyle(color: AppColors.error, fontWeight: AppFontWeight.bold)),
                          const TextSpan(text: '.\n'),
                          const TextSpan(text: 'You have chosen comfort '),
                          TextSpan(text: '$comfortChoices times', style: const TextStyle(color: AppColors.error, fontWeight: AppFontWeight.bold)),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

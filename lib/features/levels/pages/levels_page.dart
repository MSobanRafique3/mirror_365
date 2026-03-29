import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/services/level_service.dart';
import '../../../core/services/journey_time_service.dart';
import '../bloc/levels_bloc.dart';
import '../../../data/models/models.dart';

class LevelsPage extends StatelessWidget {
  const LevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LevelsBloc(
        levelRepo: getIt<LevelRepository>(),
        dayRepo: getIt<DayRecordRepository>(),
        levelService: getIt<LevelService>(),
        timeService: getIt<JourneyTimeService>(),
      )..add(const LevelsLoadRequested()),
      child: const _LevelsView(),
    );
  }
}

class _LevelsView extends StatelessWidget {
  const _LevelsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DISCIPLINE RANK', style: TextStyle(color: AppColors.primary, letterSpacing: 2.0)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocBuilder<LevelsBloc, LevelsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return CustomScrollView(
            slivers: [
              if (state.currentDropWarningActive)
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    color: AppColors.error.withOpacity(0.1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'YOUR DISCIPLINE IS SLIPPING. ${state.dropDaysRemaining} DAYS TO RECOVER OR YOU DROP.',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: AppFontSize.sm,
                              fontWeight: AppFontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      const Text(
                        'CURRENT LEVEL',
                        style: TextStyle(color: AppColors.textDisabled, letterSpacing: 2.0, fontSize: AppFontSize.xs),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'LEVEL ${state.currentLevel}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 48,
                          fontWeight: AppFontWeight.bold,
                          letterSpacing: 4.0,
                        ),
                      ),
                      Text(
                        state.currentLevelName.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppFontSize.xl,
                          letterSpacing: 6.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Progress to next
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.divider),
                          color: AppColors.surfaceVariant,
                        ),
                        child: Text(
                          state.nextLevelRequirementStr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                  child: Text(
                    'HISTORY',
                    style: TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: AppFontSize.xs,
                      letterSpacing: 2.0,
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final event = state.timelineEvents[index];
                    return _TimelineTile(event: event);
                  },
                  childCount: state.timelineEvents.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
            ],
          );
        },
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final LevelModel event;

  const _TimelineTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final bool isDrop = !event.neverDropped;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              'DAY ${event.unlockedAt}',
              style: const TextStyle(
                color: AppColors.textDisabled,
                fontSize: AppFontSize.sm,
                fontWeight: AppFontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 2,
            height: 40,
            color: AppColors.divider,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDrop ? AppColors.error : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REACHED LEVEL ${event.currentLevel}: ${event.levelName.toUpperCase()}',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppFontSize.md,
                    fontWeight: isDrop ? AppFontWeight.regular : AppFontWeight.bold,
                    decoration: isDrop ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (isDrop) ...[
                  const SizedBox(height: 4),
                  Text(
                    'LOST ON DAY ${event.droppedAt}',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: AppFontSize.xs,
                      fontWeight: AppFontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

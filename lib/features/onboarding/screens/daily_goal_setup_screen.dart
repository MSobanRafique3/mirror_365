import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/journey_goal_model.dart';

const List<_Preset> _presets = [
  _Preset('5 Daily Prayers', 'Complete all 5 prayers on time.',
      '5 prayers'),
  _Preset('Exercise', 'Physical training every day.', '1 session'),
  _Preset('Read', 'Read at least 10 pages daily.', '10 pages'),
  _Preset('Cold Shower', 'Cold shower every morning.', '1 shower'),
  _Preset('No Social Media', 'Zero social media for the day.',
      '0 minutes'),
  _Preset('Sleep by 11PM', 'Be in bed before 11PM.', '11:00 PM'),
  _Preset('Journaling', 'Write at least 200 words.', '200 words'),
];

class _Preset {
  final String title;
  final String description;
  final String target;

  const _Preset(this.title, this.description, this.target);
}

class DailyGoalSetupScreenFull extends StatelessWidget {
  const DailyGoalSetupScreenFull({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final drafts = state.dailyGoals;
        final canAdd = drafts.length < 7;

        // Which presets are already used by title?
        final usedTitles =
            drafts.map((d) => d.title.toLowerCase()).toSet();

        return OnboardingScaffold(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.xl,
            bottom: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WHAT WILL YOU DO\nEVERY SINGLE DAY?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppFontSize.xxl,
                  fontWeight: AppFontWeight.extraBold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Up to 7 daily goals. These define your daily score.',
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: AppFontSize.sm,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Preset chips
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: _presets.map((preset) {
                  final used =
                      usedTitles.contains(preset.title.toLowerCase());
                  final full = !canAdd;
                  final disabled = used || full;
                  return GestureDetector(
                    onTap: disabled ? null : () => _applyPreset(context, state, preset),
                    child: AnimatedContainer(
                      duration: AppDuration.fast,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: used
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.surface,
                        border: Border.all(
                          color: used
                              ? AppColors.primary
                              : disabled
                                  ? AppColors.divider.withValues(alpha: 0.3)
                                  : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        preset.title,
                        style: TextStyle(
                          color: used
                              ? AppColors.primary
                              : disabled
                                  ? AppColors.textDisabled.withValues(alpha: 0.4)
                                  : AppColors.textSecondary,
                          fontSize: AppFontSize.sm,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.md),
              const OnboardingDivider(label: 'YOUR GOALS'),
              const SizedBox(height: AppSpacing.sm),

              // Goal cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...List.generate(drafts.length, (i) {
                        final draft = drafts[i];
                        return GoalInputCard(
                          key: ValueKey('daily_$i'),
                          index: i,
                          categoryLabel: 'DAILY GOAL',
                          initialTitle: draft.title,
                          initialDescription: draft.description,
                          initialTarget: draft.targetValue,
                          onChanged: (t, d, tv) =>
                              context.read<OnboardingBloc>().add(
                                    OnboardingUpdateGoal(
                                      category: GoalCategory.daily,
                                      index: i,
                                      title: t,
                                      description: d,
                                      targetValue: tv,
                                    ),
                                  ),
                        );
                      }),

                      if (canAdd)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: GestureDetector(
                            onTap: () => context
                                .read<OnboardingBloc>()
                                .add(const OnboardingAddGoalCard(GoalCategory.daily)),
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      color: AppColors.textDisabled, size: 18),
                                  SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'ADD ANOTHER DAILY GOAL',
                                    style: TextStyle(
                                      color: AppColors.textDisabled,
                                      fontSize: AppFontSize.xs,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),
              OnboardingPrimaryButton(
                label: 'NEXT',
                onPressed: state.canProceedFromDaily
                    ? () => context
                        .read<OnboardingBloc>()
                        .add(const OnboardingNextStep())
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  void _applyPreset(
      BuildContext context, OnboardingState state, _Preset preset) {
    final drafts = state.dailyGoals;
    // Find first empty card or add new
    final emptyIndex = drafts.indexWhere((d) => d.title.isEmpty);
    if (emptyIndex != -1) {
      context.read<OnboardingBloc>().add(OnboardingUpdateGoal(
            category: GoalCategory.daily,
            index: emptyIndex,
            title: preset.title,
            description: preset.description,
            targetValue: preset.target,
          ));
    } else {
      // Add new card first, then update it
      context
          .read<OnboardingBloc>()
          .add(const OnboardingAddGoalCard(GoalCategory.daily));
      // Update on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final newIndex = context.read<OnboardingBloc>().state.dailyGoals.length - 1;
        if (newIndex >= 0) {
          context.read<OnboardingBloc>().add(OnboardingUpdateGoal(
                category: GoalCategory.daily,
                index: newIndex,
                title: preset.title,
                description: preset.description,
                targetValue: preset.target,
              ));
        }
      });
    }
  }
}

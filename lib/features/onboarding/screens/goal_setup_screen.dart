import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/journey_goal_model.dart';

/// Reusable goal setup screen — drives Yearly, Monthly, and Daily screens.
class GoalSetupScreen extends StatelessWidget {
  final GoalCategory category;
  final String headline;
  final String subtext;
  final int maxCards;

  const GoalSetupScreen({
    super.key,
    required this.category,
    required this.headline,
    required this.subtext,
    required this.maxCards,
  });

  String get _categoryLabel {
    switch (category) {
      case GoalCategory.yearly:
        return 'YEARLY GOAL';
      case GoalCategory.monthly:
        return 'MONTHLY GOAL';
      case GoalCategory.daily:
        return 'DAILY GOAL';
    }
  }

  bool _canProceed(OnboardingState state) {
    switch (category) {
      case GoalCategory.yearly:
        return state.canProceedFromYearly;
      case GoalCategory.monthly:
        return state.canProceedFromMonthly;
      case GoalCategory.daily:
        return state.canProceedFromDaily;
    }
  }

  List<GoalDraft> _getDrafts(OnboardingState state) {
    switch (category) {
      case GoalCategory.yearly:
        return state.yearlyGoals;
      case GoalCategory.monthly:
        return state.monthlyGoals;
      case GoalCategory.daily:
        return state.dailyGoals;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final drafts = _getDrafts(state);
        final canAdd = drafts.length < maxCards;

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
              // Header
              Text(
                headline,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: AppFontSize.xxl,
                  fontWeight: AppFontWeight.extraBold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtext,
                style: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: AppFontSize.sm,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Goal cards
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...List.generate(drafts.length, (i) {
                        final draft = drafts[i];
                        return GoalInputCard(
                          key: ValueKey('${category.name}_$i'),
                          index: i,
                          categoryLabel: _categoryLabel,
                          initialTitle: draft.title,
                          initialDescription: draft.description,
                          initialTarget: draft.targetValue,
                          onChanged: (t, d, tv) =>
                              context.read<OnboardingBloc>().add(
                                    OnboardingUpdateGoal(
                                      category: category,
                                      index: i,
                                      title: t,
                                      description: d,
                                      targetValue: tv,
                                    ),
                                  ),
                        );
                      }),

                      // Add card button
                      if (canAdd)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.md),
                          child: GestureDetector(
                            onTap: () => context
                                .read<OnboardingBloc>()
                                .add(OnboardingAddGoalCard(category)),
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.divider,
                                    style: BorderStyle.solid),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add,
                                    color: AppColors.textDisabled,
                                    size: 18,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'ADD ANOTHER $_categoryLabel',
                                    style: const TextStyle(
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
                onPressed: _canProceed(state)
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
}

// ─── Three concrete screens ───────────────────────────────────────────────────

class YearlyGoalSetupScreen extends StatelessWidget {
  const YearlyGoalSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GoalSetupScreen(
      category: GoalCategory.yearly,
      headline: 'WHAT WILL YOU\nACHIEVE THIS YEAR?',
      subtext: 'Up to 3 yearly goals. Cannot be removed once added.',
      maxCards: 3,
    );
  }
}

class MonthlyGoalSetupScreen extends StatelessWidget {
  const MonthlyGoalSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GoalSetupScreen(
      category: GoalCategory.monthly,
      headline: 'WHAT WILL YOU DO\nEVERY MONTH?',
      subtext: 'Up to 5 monthly goals. Cannot be removed once added.',
      maxCards: 5,
    );
  }
}

class DailyGoalSetupScreen extends StatelessWidget {
  const DailyGoalSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return const GoalSetupScreen(
          category: GoalCategory.daily,
          headline: 'WHAT WILL YOU DO\nEVERY SINGLE DAY?',
          subtext:
              'Up to 7 daily goals. These define your daily score.',
          maxCards: 7,
          // Daily screen injects preset chips via a custom builder.
          // The GoalSetupScreen handles the chips through the child
          // slot below — we override with a subclass that prepends chips.
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_widgets.dart';
import '../../../core/constants/app_constants.dart';

class FinalConfirmationScreen extends StatefulWidget {
  const FinalConfirmationScreen({super.key});

  @override
  State<FinalConfirmationScreen> createState() =>
      _FinalConfirmationScreenState();
}

class _FinalConfirmationScreenState extends State<FinalConfirmationScreen> {
  bool _wasSaving = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (_wasSaving && !state.isSaving && state.errorMessage == null) {
          context.go(AppRoutes.dashboard);
        }
        _wasSaving = state.isSaving;
      },
      child: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          return OnboardingScaffold(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'READY TO\nBEGIN.',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 36,
                    fontWeight: AppFontWeight.extraBold,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Summary
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _GoalSummarySection(
                            label: 'YEARLY',
                            goals: state.yearlyGoals,
                            color: AppColors.primary),
                        const SizedBox(height: AppSpacing.lg),
                        _GoalSummarySection(
                            label: 'MONTHLY',
                            goals: state.monthlyGoals,
                            color: AppColors.primaryLight),
                        const SizedBox(height: AppSpacing.lg),
                        _GoalSummarySection(
                            label: 'DAILY',
                            goals: state.dailyGoals,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Warning banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.error.withValues(alpha: 0.6)),
                    color: AppColors.error.withValues(alpha: 0.06),
                  ),
                  child: const Text(
                    'Once you press START, the 365-day clock begins.\nIt will not stop.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: AppFontSize.md,
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Error
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: AppFontSize.sm,
                      ),
                    ),
                  ),

                // START button
                OnboardingPrimaryButton(
                  label: 'START',
                  isLoading: state.isSaving,
                  onPressed: state.isSaving
                      ? null
                      : () => context
                          .read<OnboardingBloc>()
                          .add(const OnboardingConfirmStart()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GoalSummarySection extends StatelessWidget {
  final String label;
  final List<GoalDraft> goals;
  final Color color;

  const _GoalSummarySection({
    required this.label,
    required this.goals,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label GOALS',
          style: TextStyle(
            color: color,
            fontSize: AppFontSize.xs,
            fontWeight: AppFontWeight.bold,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...goals.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 7),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: AppFontSize.md,
                            fontWeight: AppFontWeight.medium,
                          ),
                        ),
                        Text(
                          g.targetValue,
                          style: const TextStyle(
                            color: AppColors.textDisabled,
                            fontSize: AppFontSize.sm,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

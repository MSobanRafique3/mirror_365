import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_widgets.dart';
import '../../../core/constants/app_constants.dart';

const List<String> _rules = [
  'Once started, the clock never stops.',
  'Goals can be added. Never removed. Never edited.',
  'A failed day is failed forever.',
  'Uninstalling does not pause your journey.',
  'The app will never lie to you. Even when you want it to.',
  'You cannot negotiate with time.',
];

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        final allRevealed = state.rulesRevealed >= 6;
        return OnboardingScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'THE RULES',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppFontSize.xxl,
                  fontWeight: AppFontWeight.extraBold,
                  letterSpacing: 3.0,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Tap to reveal each rule.',
                style: TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: AppFontSize.sm,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Rules list
              Expanded(
                child: ListView.separated(
                  itemCount: 6,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final revealed = i < state.rulesRevealed;
                    return _RuleTile(
                      index: i,
                      text: _rules[i],
                      revealed: revealed,
                      onTap: () {
                        if (!revealed) {
                          context
                              .read<OnboardingBloc>()
                              .add(const OnboardingRevealNextRule());
                        }
                      },
                    );
                  },
                ),
              ),

              // Checkbox + button (appear after all rules revealed)
              AnimatedSize(
                duration: AppDuration.slow,
                curve: Curves.easeInOut,
                child: allRevealed
                    ? _BottomSection(acknowledged: state.rulesAcknowledged)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RuleTile extends StatelessWidget {
  final int index;
  final String text;
  final bool revealed;
  final VoidCallback onTap;

  const _RuleTile({
    required this.index,
    required this.text,
    required this.revealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.normal,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: revealed ? AppColors.surface : AppColors.background,
          border: Border.all(
            color: revealed ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number
            SizedBox(
              width: 28,
              child: Text(
                '${index + 1}.',
                style: TextStyle(
                  color: revealed
                      ? AppColors.primary
                      : AppColors.textDisabled,
                  fontSize: AppFontSize.md,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Text or placeholder
            Expanded(
              child: revealed
                  ? Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppFontSize.md,
                        height: 1.5,
                      ),
                    )
                  : Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
            ),
            if (!revealed)
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm),
                child: Icon(
                  Icons.touch_app_outlined,
                  color: AppColors.textDisabled,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomSection extends StatelessWidget {
  final bool acknowledged;
  const _BottomSection({required this.acknowledged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        const OnboardingDivider(),
        const SizedBox(height: AppSpacing.md),

        // Checkbox row
        GestureDetector(
          onTap: () => context
              .read<OnboardingBloc>()
              .add(const OnboardingToggleAcknowledgement()),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppDuration.fast,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: acknowledged
                      ? AppColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: acknowledged
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                child: acknowledged
                    ? const Icon(Icons.check,
                        color: AppColors.background, size: 16)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                  'I understand. There is no going back.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppFontSize.md,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        OnboardingPrimaryButton(
          label: 'BEGIN SETUP',
          onPressed: acknowledged
              ? () => context
                  .read<OnboardingBloc>()
                  .add(const OnboardingNextStep())
              : null,
        ),
      ],
    );
  }
}

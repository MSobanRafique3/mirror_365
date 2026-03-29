import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_widgets.dart';
import '../../../core/constants/app_constants.dart';

class ReasonVaultScreen extends StatefulWidget {
  const ReasonVaultScreen({super.key});

  @override
  State<ReasonVaultScreen> createState() => _ReasonVaultScreenState();
}

class _ReasonVaultScreenState extends State<ReasonVaultScreen> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final initial = context.read<OnboardingBloc>().state.reasonText;
    _ctrl = TextEditingController(text: initial);
    _ctrl.addListener(() {
      context
          .read<OnboardingBloc>()
          .add(OnboardingUpdateReason(_ctrl.text));
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      buildWhen: (prev, curr) =>
          prev.reasonText != curr.reasonText ||
          prev.step != curr.step,
      builder: (context, state) {
        final charCount = state.reasonText.trim().length;
        final enough = charCount >= 50;

        return OnboardingScaffold(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WHY ARE YOU\nDOING THIS?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: AppFontSize.xxl,
                  fontWeight: AppFontWeight.extraBold,
                  letterSpacing: 1.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Lock warning
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                  color: AppColors.error.withValues(alpha: 0.05),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: AppColors.error,
                      size: 16,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'This will be locked. You will only see it again when you fail.',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: AppFontSize.sm,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Text area
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppFontSize.lg,
                    height: 1.7,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Write your reason here. Be honest. Nobody else will read this.',
                    hintStyle: TextStyle(
                      color: AppColors.textDisabled.withValues(alpha: 0.6),
                      fontSize: AppFontSize.md,
                      height: 1.6,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.divider),
                      borderRadius: BorderRadius.zero,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.divider),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 1),
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                  cursorColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Character counter
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$charCount / 50 minimum',
                    style: TextStyle(
                      color: enough ? AppColors.success : AppColors.textDisabled,
                      fontSize: AppFontSize.xs,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              OnboardingPrimaryButton(
                label: 'NEXT',
                onPressed: enough
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

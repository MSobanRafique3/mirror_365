import 'package:equatable/equatable.dart';

// ─── Goal Draft ───────────────────────────────────────────────────────────────

/// Temporary in-memory goal before being persisted on START.
class GoalDraft extends Equatable {
  final String title;
  final String description;
  final String targetValue;

  const GoalDraft({
    this.title = '',
    this.description = '',
    this.targetValue = '',
  });

  bool get isValid =>
      title.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      targetValue.trim().isNotEmpty;

  GoalDraft copyWith({
    String? title,
    String? description,
    String? targetValue,
  }) {
    return GoalDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
    );
  }

  @override
  List<Object?> get props => [title, description, targetValue];
}

// ─── Onboarding Step ─────────────────────────────────────────────────────────

enum OnboardingStep {
  welcome,
  rules,
  yearlyGoals,
  monthlyGoals,
  dailyGoals,
  reasonVault,
  finalConfirmation,
}

// ─── State ───────────────────────────────────────────────────────────────────

class OnboardingState extends Equatable {
  final OnboardingStep step;

  // Rules screen
  final int rulesRevealed;       // 0–6
  final bool rulesAcknowledged;  // checkbox ticked

  // Goals
  final List<GoalDraft> yearlyGoals;
  final List<GoalDraft> monthlyGoals;
  final List<GoalDraft> dailyGoals;

  // Reason vault
  final String reasonText;

  // Submission
  final bool isSaving;
  final String? errorMessage;

  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.rulesRevealed = 0,
    this.rulesAcknowledged = false,
    this.yearlyGoals = const [GoalDraft()],
    this.monthlyGoals = const [GoalDraft()],
    this.dailyGoals = const [GoalDraft()],
    this.reasonText = '',
    this.isSaving = false,
    this.errorMessage,
  });

  bool get canProceedFromRules =>
      rulesRevealed >= 6 && rulesAcknowledged;

  bool get canProceedFromYearly =>
      yearlyGoals.isNotEmpty && yearlyGoals.every((g) => g.isValid);

  bool get canProceedFromMonthly =>
      monthlyGoals.isNotEmpty && monthlyGoals.every((g) => g.isValid);

  bool get canProceedFromDaily =>
      dailyGoals.isNotEmpty && dailyGoals.every((g) => g.isValid);

  bool get canProceedFromReason => reasonText.trim().length >= 50;

  OnboardingState copyWith({
    OnboardingStep? step,
    int? rulesRevealed,
    bool? rulesAcknowledged,
    List<GoalDraft>? yearlyGoals,
    List<GoalDraft>? monthlyGoals,
    List<GoalDraft>? dailyGoals,
    String? reasonText,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      rulesRevealed: rulesRevealed ?? this.rulesRevealed,
      rulesAcknowledged: rulesAcknowledged ?? this.rulesAcknowledged,
      yearlyGoals: yearlyGoals ?? this.yearlyGoals,
      monthlyGoals: monthlyGoals ?? this.monthlyGoals,
      dailyGoals: dailyGoals ?? this.dailyGoals,
      reasonText: reasonText ?? this.reasonText,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        step,
        rulesRevealed,
        rulesAcknowledged,
        yearlyGoals,
        monthlyGoals,
        dailyGoals,
        reasonText,
        isSaving,
        errorMessage,
      ];
}

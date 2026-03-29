import 'package:equatable/equatable.dart';
import '../../../data/models/journey_goal_model.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object?> get props => [];
}

// ─── Navigation ──────────────────────────────────────────────────────────────

class OnboardingNextStep extends OnboardingEvent {
  const OnboardingNextStep();
}

// ─── Rules ───────────────────────────────────────────────────────────────────

class OnboardingRevealNextRule extends OnboardingEvent {
  const OnboardingRevealNextRule();
}

class OnboardingToggleAcknowledgement extends OnboardingEvent {
  const OnboardingToggleAcknowledgement();
}

// ─── Goals ───────────────────────────────────────────────────────────────────

class OnboardingAddGoalCard extends OnboardingEvent {
  final GoalCategory category;
  const OnboardingAddGoalCard(this.category);
  @override
  List<Object?> get props => [category];
}

class OnboardingUpdateGoal extends OnboardingEvent {
  final GoalCategory category;
  final int index;
  final String? title;
  final String? description;
  final String? targetValue;

  const OnboardingUpdateGoal({
    required this.category,
    required this.index,
    this.title,
    this.description,
    this.targetValue,
  });

  @override
  List<Object?> get props => [category, index, title, description, targetValue];
}

// ─── Reason Vault ────────────────────────────────────────────────────────────

class OnboardingUpdateReason extends OnboardingEvent {
  final String text;
  const OnboardingUpdateReason(this.text);
  @override
  List<Object?> get props => [text];
}

// ─── Final ───────────────────────────────────────────────────────────────────

class OnboardingConfirmStart extends OnboardingEvent {
  const OnboardingConfirmStart();
}

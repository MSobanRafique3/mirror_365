import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/journey_goal_model.dart';
import '../../../data/repositories/user_journey_repository.dart';
import '../../../data/repositories/journey_goal_repository.dart';
import '../../../data/repositories/monthly_confession_repository.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

export 'onboarding_event.dart';
export 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final UserJourneyRepository _journeyRepo;
  final JourneyGoalRepository _goalRepo;
  final MonthlyConfessionRepository _confessionRepo;

  static const int _maxYearly = 3;
  static const int _maxMonthly = 5;
  static const int _maxDaily = 7;

  OnboardingBloc({
    required UserJourneyRepository journeyRepo,
    required JourneyGoalRepository goalRepo,
    required MonthlyConfessionRepository confessionRepo,
  })  : _journeyRepo = journeyRepo,
        _goalRepo = goalRepo,
        _confessionRepo = confessionRepo,
        super(const OnboardingState()) {
    on<OnboardingNextStep>(_onNextStep);
    on<OnboardingRevealNextRule>(_onRevealNextRule);
    on<OnboardingToggleAcknowledgement>(_onToggleAck);
    on<OnboardingAddGoalCard>(_onAddGoalCard);
    on<OnboardingUpdateGoal>(_onUpdateGoal);
    on<OnboardingUpdateReason>(_onUpdateReason);
    on<OnboardingConfirmStart>(_onConfirmStart);
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  void _onNextStep(OnboardingNextStep event, Emitter<OnboardingState> emit) {
    const steps = OnboardingStep.values;
    final nextIndex = state.step.index + 1;
    if (nextIndex < steps.length) {
      emit(state.copyWith(step: steps[nextIndex], clearError: true));
    }
  }

  // ─── Rules ─────────────────────────────────────────────────────────────────

  void _onRevealNextRule(
      OnboardingRevealNextRule event, Emitter<OnboardingState> emit) {
    if (state.rulesRevealed < 6) {
      emit(state.copyWith(rulesRevealed: state.rulesRevealed + 1));
    }
  }

  void _onToggleAck(
      OnboardingToggleAcknowledgement event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(rulesAcknowledged: !state.rulesAcknowledged));
  }

  // ─── Goals ─────────────────────────────────────────────────────────────────

  void _onAddGoalCard(
      OnboardingAddGoalCard event, Emitter<OnboardingState> emit) {
    switch (event.category) {
      case GoalCategory.yearly:
        if (state.yearlyGoals.length < _maxYearly) {
          emit(state.copyWith(
              yearlyGoals: [...state.yearlyGoals, const GoalDraft()]));
        }
        break;
      case GoalCategory.monthly:
        if (state.monthlyGoals.length < _maxMonthly) {
          emit(state.copyWith(
              monthlyGoals: [...state.monthlyGoals, const GoalDraft()]));
        }
        break;
      case GoalCategory.daily:
        if (state.dailyGoals.length < _maxDaily) {
          emit(state.copyWith(
              dailyGoals: [...state.dailyGoals, const GoalDraft()]));
        }
        break;
    }
  }

  void _onUpdateGoal(
      OnboardingUpdateGoal event, Emitter<OnboardingState> emit) {
    List<GoalDraft> applyUpdate(List<GoalDraft> list) {
      final updated = List<GoalDraft>.from(list);
      if (event.index >= 0 && event.index < updated.length) {
        updated[event.index] = updated[event.index].copyWith(
          title: event.title,
          description: event.description,
          targetValue: event.targetValue,
        );
      }
      return updated;
    }

    switch (event.category) {
      case GoalCategory.yearly:
        emit(state.copyWith(yearlyGoals: applyUpdate(state.yearlyGoals)));
        break;
      case GoalCategory.monthly:
        emit(state.copyWith(monthlyGoals: applyUpdate(state.monthlyGoals)));
        break;
      case GoalCategory.daily:
        emit(state.copyWith(dailyGoals: applyUpdate(state.dailyGoals)));
        break;
    }
  }

  // ─── Reason ────────────────────────────────────────────────────────────────

  void _onUpdateReason(
      OnboardingUpdateReason event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(reasonText: event.text));
  }

  // ─── Final START ───────────────────────────────────────────────────────────

  Future<void> _onConfirmStart(
      OnboardingConfirmStart event, Emitter<OnboardingState> emit) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      // 1. Create the journey — this is the single source-of-truth timestamp.
      final journey = await _journeyRepo.createJourney();

      // 2. Persist all goal drafts (addedOnDay = 1 — day 1 of journey).
      for (final draft in state.yearlyGoals) {
        await _goalRepo.addGoal(
          title: draft.title.trim(),
          description: draft.description.trim(),
          category: GoalCategory.yearly,
          addedOnDay: 1,
          targetValue: draft.targetValue.trim(),
        );
      }
      for (final draft in state.monthlyGoals) {
        await _goalRepo.addGoal(
          title: draft.title.trim(),
          description: draft.description.trim(),
          category: GoalCategory.monthly,
          addedOnDay: 1,
          targetValue: draft.targetValue.trim(),
        );
      }
      for (final draft in state.dailyGoals) {
        await _goalRepo.addGoal(
          title: draft.title.trim(),
          description: draft.description.trim(),
          category: GoalCategory.daily,
          addedOnDay: 1,
          targetValue: draft.targetValue.trim(),
        );
      }

      // 3. Save the reason vault as month-1 confession (locked until 365).
      await _confessionRepo.createConfession(
        monthNumber: 0, // 0 = reason vault (pre-journey)
        content: state.reasonText.trim(),
        isUnlocked: false,
        writtenAtMs: journey.startTimestamp,
      );

      emit(state.copyWith(isSaving: false));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }
}

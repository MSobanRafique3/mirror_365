import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/journey_time_service.dart';
import '../../../data/repositories/monthly_confession_repository.dart';
import 'confession_event.dart';
import 'confession_state.dart';

export 'confession_event.dart';
export 'confession_state.dart';

class ConfessionBloc extends Bloc<ConfessionEvent, ConfessionState> {
  final MonthlyConfessionRepository _confessionRepo;
  final JourneyTimeService _timeService;

  ConfessionBloc({
    required MonthlyConfessionRepository confessionRepo,
    required JourneyTimeService timeService,
  })  : _confessionRepo = confessionRepo,
        _timeService = timeService,
        super(const ConfessionState()) {
    on<ConfessionLoadRequested>(_onLoadRequested);
    on<ConfessionSubmitted>(_onSubmitted);
  }

  Future<void> _onLoadRequested(
      ConfessionLoadRequested event, Emitter<ConfessionState> emit) async {
    try {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final currentDay = _timeService.currentJourneyDay(nowMs);

      final existingConfessions = _confessionRepo.getAllConfessions();
      
      // Determine the REQUIRED sequential month to write.
      // E.g., if currentDay = 45, month 1 is passed (since 45 > 30).
      // So month 1 is due. If currentDay = 95, months 1, 2, 3 are passed.
      // We must find the earliest month (1-12) that is passed but NOT written yet.
      
      int? requiredMonth;
      for (int m = 1; m <= 12; m++) {
        // Is this month passed? (Month 1 ends at day 30, Month 2 at day 60, etc.)
        if (currentDay > m * 30) {
          // Check if user already confessed for this month
          final hasConfessed = existingConfessions.any((c) => c.monthNumber == m);
          if (!hasConfessed) {
            requiredMonth = m;
            break; // Stop! sequential enforcement. We found the earliest unwritten month.
          }
        } else {
          // If we haven't even reached the end of month 'm', we can stop checking.
          break; // Stop loop, future months are definitely not due.
        }
      }

      emit(state.copyWith(
        isLoading: false,
        requiredMonthNumber: requiredMonth,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onSubmitted(
      ConfessionSubmitted event, Emitter<ConfessionState> emit) async {
    if (state.requiredMonthNumber == null) return;
    
    final text = event.text.trim();
    if (text.length < 50) {
      emit(state.copyWith(errorMessage: 'A true confession requires depth. At least 50 characters.', clearError: false));
      emit(state.copyWith(clearError: true));
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      // Note: isUnlocked is ALWAYS false until Day 365, so we lock it.
      await _confessionRepo.createConfession(
        monthNumber: state.requiredMonthNumber!,
        content: text,
        isUnlocked: false,
        writtenAtMs: nowMs,
      );

      // Successfully locked. State tells UI to switch to Locked view.
      emit(state.copyWith(
        isLoading: false,
        isLocked: true, 
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false, 
        errorMessage: 'The mirror rejected your entry. Try again.',
        clearError: false,
      ));
      emit(state.copyWith(clearError: true));
    }
  }
}

/// JourneyTimeService
///
/// All calculations are based purely on elapsed milliseconds from
/// [startTimestamp] — never on the device's local timezone or wall-clock
/// date fields. This makes the service timezone-independent and deterministic.
///
/// Journey structure:
///   • 365 days total, numbered 1–365.
///   • Each "day" is exactly 86,400,000 ms (24 h) from [startTimestamp].
///   • 12 months of exactly 30 days (30 × 12 = 360 days + Final Five days 361–365).
///   • Check-in window: the LAST 6 hours of each 24 h period
///     (i.e. hours 18–24 of each journey day).
///
class JourneyTimeService {
  static const int msPerDay = 86400000; // 24 * 60 * 60 * 1000
  static const int msPerHour = 3600000;
  static const int daysPerMonth = 30;
  static const int totalDays = 365;
  static const int checkInWindowHours = 6; // last N hours of each day
  static const int firstSpecialDay = 361;

  /// The epoch-ms timestamp from which the journey started.
  final int startTimestamp;

  const JourneyTimeService({required this.startTimestamp});

  // ─── Core elapsed-time helper ─────────────────────────────────────────────

  /// Elapsed milliseconds since journey start, at the given [nowMs].
  /// [nowMs] defaults to [DateTime.now().millisecondsSinceEpoch].
  int elapsedMs([int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - startTimestamp;
    return elapsed < 0 ? 0 : elapsed;
  }

  // ─── Journey Day ─────────────────────────────────────────────────────────

  /// Current journey day (1-based). Returns 0 if journey hasn't started.
  /// Caps at 365.
  int currentJourneyDay([int? nowMs]) {
    final elapsed = elapsedMs(nowMs);
    final day = (elapsed ~/ msPerDay) + 1;
    return day.clamp(1, totalDays);
  }

  /// Journey day for an arbitrary epoch-ms timestamp.
  int journeyDayFor(int timestampMs) {
    final elapsed = timestampMs - startTimestamp;
    if (elapsed < 0) return 0;
    return ((elapsed ~/ msPerDay) + 1).clamp(1, totalDays);
  }

  // ─── Month & Day-in-Month ─────────────────────────────────────────────────

  /// Month number (1–12) for a given journey day.
  int monthNumberFor(int journeyDay) {
    final month = ((journeyDay - 1) ~/ daysPerMonth) + 1;
    return month.clamp(1, 12);
  }

  /// Day within the month (1–30) for a given journey day.
  int dayInMonthFor(int journeyDay) {
    final dayInMonth = ((journeyDay - 1) % daysPerMonth) + 1;
    return dayInMonth.clamp(1, daysPerMonth);
  }

  /// Current month (1–12).
  int get currentMonth => monthNumberFor(currentJourneyDay());

  /// Current day-in-month (1–30).
  int get currentDayInMonth => dayInMonthFor(currentJourneyDay());

  // ─── Timestamps for a given day ──────────────────────────────────────────

  /// Epoch ms when journey day [d] starts.
  int dayStartMs(int d) => startTimestamp + (d - 1) * msPerDay;

  /// Epoch ms when journey day [d] ends (inclusive last ms).
  int dayEndMs(int d) => dayStartMs(d) + msPerDay - 1;

  // ─── Remaining time ───────────────────────────────────────────────────────

  /// Days remaining in the 365-day journey (0 when complete).
  int daysRemaining([int? nowMs]) {
    final day = currentJourneyDay(nowMs);
    return (totalDays - day).clamp(0, totalDays);
  }

  /// Milliseconds until the current journey day ends.
  int msUntilDayEnd([int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final day = currentJourneyDay(now);
    return dayEndMs(day) - now;
  }

  // ─── Check-in Window ─────────────────────────────────────────────────────

  /// Whether the check-in window is currently open.
  ///
  /// The window opens in the last [checkInWindowHours] hours of each
  /// journey day (hours 18–24 of the 24 h period).
  bool isCheckInWindowOpen([int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final day = currentJourneyDay(now);
    final dayStart = dayStartMs(day);
    final elapsedInDay = now - dayStart; // ms since this day started
    const windowStart = msPerDay - (checkInWindowHours * msPerHour);
    return elapsedInDay >= windowStart;
  }

  /// Epoch ms when the check-in window opens for journey day [d].
  int checkInWindowStartMs(int d) {
    return dayStartMs(d) + msPerDay - (checkInWindowHours * msPerHour);
  }

  /// Milliseconds until today's check-in window opens.
  /// Returns 0 if the window is already open.
  int msUntilCheckInWindow([int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    if (isCheckInWindowOpen(now)) return 0;
    final day = currentJourneyDay(now);
    final windowStart = checkInWindowStartMs(day);
    return (windowStart - now).clamp(0, msPerDay).toInt();
  }

  // ─── Special days ─────────────────────────────────────────────────────────

  /// True if [journeyDay] is one of the Final Five (361–365).
  bool isSpecialDay(int journeyDay) => journeyDay >= firstSpecialDay;

  bool get todayIsSpecialDay => isSpecialDay(currentJourneyDay());

  // ─── Journey state ────────────────────────────────────────────────────────

  /// True if the journey has started (startTimestamp is in the past).
  bool get hasStarted =>
      DateTime.now().millisecondsSinceEpoch >= startTimestamp;

  /// True if all 365 days have elapsed.
  bool get isComplete => currentJourneyDay() >= totalDays &&
      elapsedMs() >= totalDays * msPerDay;

  // ─── Utility: human-readable breakdown ────────────────────────────────────

  /// Returns a [JourneySnapshot] with all key time values pre-computed for a
  /// given [nowMs] (defaults to now). Useful for passing to UI layer.
  JourneySnapshot snapshot([int? nowMs]) {
    final now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final jd = currentJourneyDay(now);
    return JourneySnapshot(
      journeyDay: jd,
      monthNumber: monthNumberFor(jd),
      dayInMonth: dayInMonthFor(jd),
      daysRemaining: daysRemaining(now),
      isCheckInWindowOpen: isCheckInWindowOpen(now),
      msUntilCheckInWindow: msUntilCheckInWindow(now),
      msUntilDayEnd: msUntilDayEnd(now),
      isSpecialDay: isSpecialDay(jd),
      isComplete: isComplete,
    );
  }
}

/// Immutable snapshot of all journey-time values at a single point in time.
class JourneySnapshot {
  final int journeyDay;
  final int monthNumber;
  final int dayInMonth;
  final int daysRemaining;
  final bool isCheckInWindowOpen;
  final int msUntilCheckInWindow;
  final int msUntilDayEnd;
  final bool isSpecialDay;
  final bool isComplete;

  const JourneySnapshot({
    required this.journeyDay,
    required this.monthNumber,
    required this.dayInMonth,
    required this.daysRemaining,
    required this.isCheckInWindowOpen,
    required this.msUntilCheckInWindow,
    required this.msUntilDayEnd,
    required this.isSpecialDay,
    required this.isComplete,
  });

  @override
  String toString() =>
      'JourneySnapshot(day=$journeyDay, month=$monthNumber, '
      'dayInMonth=$dayInMonth, remaining=$daysRemaining, '
      'checkIn=$isCheckInWindowOpen, special=$isSpecialDay, '
      'complete=$isComplete)';
}

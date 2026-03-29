/// Goal categories
enum GoalCategory {
  health,
  mindset,
  career,
  relationships,
  finance,
  creativity,
  education,
  spirituality,
  custom,
}

/// Goal status
enum GoalStatus {
  active,
  completed,
  paused,
  abandoned,
}

/// Goal priority
enum GoalPriority {
  low,
  medium,
  high,
  critical,
}

/// Session type (timer modes)
enum SessionType {
  focus,
  reflection,
  review,
  freeWrite,
}

/// Timer state
enum TimerState {
  idle,
  running,
  paused,
  completed,
}

/// User level tiers
enum LevelTier {
  seedling,    // 0–7 days
  sprouting,   // 8–30 days
  growing,     // 31–90 days
  flourishing, // 91–180 days
  thriving,    // 181–365 days
  transcendent, // 365+ days
}

/// Onboarding step
enum OnboardingStep {
  welcome,
  name,
  intention,
  commitment,
  complete,
}

/// Chart period
enum ChartPeriod {
  week,
  month,
  quarter,
  year,
}

/// Mirror prompt type
enum MirrorPromptType {
  morning,
  evening,
  weekly,
  random,
}

/// Final Five entry type
enum FinalFiveType {
  gratitude,
  achievement,
  lesson,
  intention,
  affirmation,
}

/// App theme mode (always dark for now, kept for extensibility)
enum AppThemeMode {
  dark,
  light,
  system,
}

extension GoalCategoryExtension on GoalCategory {
  String get label {
    switch (this) {
      case GoalCategory.health:
        return 'Health';
      case GoalCategory.mindset:
        return 'Mindset';
      case GoalCategory.career:
        return 'Career';
      case GoalCategory.relationships:
        return 'Relationships';
      case GoalCategory.finance:
        return 'Finance';
      case GoalCategory.creativity:
        return 'Creativity';
      case GoalCategory.education:
        return 'Education';
      case GoalCategory.spirituality:
        return 'Spirituality';
      case GoalCategory.custom:
        return 'Custom';
    }
  }

  String get emoji {
    switch (this) {
      case GoalCategory.health:
        return '💪';
      case GoalCategory.mindset:
        return '🧠';
      case GoalCategory.career:
        return '🚀';
      case GoalCategory.relationships:
        return '❤️';
      case GoalCategory.finance:
        return '💰';
      case GoalCategory.creativity:
        return '🎨';
      case GoalCategory.education:
        return '📚';
      case GoalCategory.spirituality:
        return '🕊️';
      case GoalCategory.custom:
        return '⭐';
    }
  }
}

extension LevelTierExtension on LevelTier {
  String get label {
    switch (this) {
      case LevelTier.seedling:
        return 'Seedling';
      case LevelTier.sprouting:
        return 'Sprouting';
      case LevelTier.growing:
        return 'Growing';
      case LevelTier.flourishing:
        return 'Flourishing';
      case LevelTier.thriving:
        return 'Thriving';
      case LevelTier.transcendent:
        return 'Transcendent';
    }
  }
}

extension ChartPeriodExtension on ChartPeriod {
  String get label {
    switch (this) {
      case ChartPeriod.week:
        return 'Week';
      case ChartPeriod.month:
        return 'Month';
      case ChartPeriod.quarter:
        return 'Quarter';
      case ChartPeriod.year:
        return 'Year';
    }
  }
}

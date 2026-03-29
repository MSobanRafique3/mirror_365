import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceVariant = Color(0xFF0A0A0A);
  static const Color primary = Color(0xFFC8A951); // gold
  static const Color primaryDark = Color(0xFF9E7D30);
  static const Color primaryLight = Color(0xFFE2C97A);
  static const Color error = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textDisabled = Color(0xFF555555);
  static const Color divider = Color(0xFF2A2A2A);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color overlay = Color(0x80000000);
}

// ─── Spacing ──────────────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

// ─── Border Radius ────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 100.0;
}

// ─── Font Sizes ───────────────────────────────────────────────────────────────

class AppFontSize {
  AppFontSize._();

  static const double xs = 10.0;
  static const double sm = 12.0;
  static const double md = 14.0;
  static const double lg = 16.0;
  static const double xl = 18.0;
  static const double xxl = 22.0;
  static const double xxxl = 28.0;
  static const double display = 36.0;
  static const double hero = 48.0;
}

// ─── Font Weights ─────────────────────────────────────────────────────────────

class AppFontWeight {
  AppFontWeight._();

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

// ─── Durations ────────────────────────────────────────────────────────────────

class AppDuration {
  AppDuration._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);
}

// ─── Hive Box Names ───────────────────────────────────────────────────────────

class HiveBoxes {
  HiveBoxes._();

  // ── Legacy boxes (phase 1) ────────────────────────────────────────────
  static const String goals = 'goals_box';
  static const String sessions = 'sessions_box';
  static const String userProfile = 'user_profile_box';
  static const String settings = 'settings_box';
  static const String reflections = 'reflections_box';
  static const String finalFive = 'final_five_box';

  // ── Journey boxes (phase 2) ───────────────────────────────────────────
  static const String journey = 'journey_box';
  static const String journeyGoals = 'journey_goals_box';
  static const String dayRecords = 'day_records_box';
  static const String goalEntries = 'goal_entries_box';
  static const String confessions = 'confessions_box';
  static const String levels = 'levels_box';
}

// ─── Hive Type IDs ────────────────────────────────────────────────────────────

class HiveTypeIds {
  HiveTypeIds._();

  // ── Legacy type IDs (phase 1) ─────────────────────────────────────────
  static const int goal = 0;
  static const int session = 1;
  static const int userProfile = 2;
  static const int reflection = 3;
  static const int finalFiveEntry = 4;

  // ── Journey type IDs (phase 2) ────────────────────────────────────────
  static const int userJourney = 5;
  static const int journeyGoal = 6;
  static const int dayRecord = 7;
  static const int goalEntry = 8;
  static const int monthlyConfession = 9;
  static const int level = 10;

  // ── Goal category enum adapter ────────────────────────────────────────
  static const int goalCategory = 11;
}

// ─── Route Names ─────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String goals = '/goals';
  static const String goalDetail = '/goals/:id';
  static const String timer = '/timer';
  static const String graphs = '/graphs';
  static const String levels = '/levels';
  static const String mirror = '/mirror';
  static const String finalFive = '/final-five';
  static const String settings = '/settings';
}

// ─── App Info ────────────────────────────────────────────────────────────────

class AppInfo {
  AppInfo._();

  static const String name = 'Mirror 365';
  static const String tagline = 'Reflect. Grow. Repeat.';
  static const String version = '1.0.0';
}

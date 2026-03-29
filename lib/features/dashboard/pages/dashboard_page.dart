import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/repositories.dart';
import '../../../core/services/journey_time_service.dart';
import '../bloc/dashboard_bloc.dart';
import '../screens/dashboard_screen.dart';
import '../screens/mirror_screen.dart';
import '../screens/silence_penalty_screen.dart';
import '../screens/reason_vault_overlay.dart';
import '../screens/level_alert_overlay.dart';
import '../screens/reckoning_day_screen.dart';
import '../../goals/pages/goals_page.dart';
import '../../mirror/screens/monthly_confession_screen.dart';
import '../../graphs/pages/graphs_page.dart';
import '../../levels/pages/levels_page.dart';
import '../../final_five/pages/final_five_shell.dart';
import '../../../core/services/daily_check_in_service.dart';
import '../../../core/services/level_service.dart';
import '../../../core/constants/app_constants.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(
        journeyRepo: getIt<UserJourneyRepository>(),
        goalRepo: getIt<JourneyGoalRepository>(),
        dayRepo: getIt<DayRecordRepository>(),
        entryRepo: getIt<GoalEntryRepository>(),
        levelRepo: getIt<LevelRepository>(),
        timeService: getIt<JourneyTimeService>(),
        prefs: getIt<SharedPreferences>(),
        checkInService: getIt<DailyCheckInService>(),
        levelService: getIt<LevelService>(),
      )..add(const DashboardLoadRequested()),
      child: const _DashboardShell(),
    );
  }
}

class _DashboardShell extends StatelessWidget {
  const _DashboardShell();

  @override
  Widget build(BuildContext context) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final currentDay = getIt<JourneyTimeService>().currentJourneyDay(nowMs);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDisabled),
      ),
      body: Stack(
        children: [
          // Base Layer
          DashboardScreen(),
          
          // Layer 1: Mirror Screen
          MirrorScreen(),
          
          // Layer 2: Silence Penalty Overlay (Covers everything until tapped)
          SilencePenaltyScreen(),

          // Layer 3: Reason Vault Overlay (Requires text input before seeing Mirror)
          ReasonVaultOverlay(),

          // Layer 4: Level Alert Overlay (Most important contextual overlay)
          LevelAlertOverlay(),
          
          // Layer 5: Reckoning Day Override
          ReckoningDayScreen(),
        ],
      ),
    );
  }
}

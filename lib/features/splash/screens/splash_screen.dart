import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/daily_check_in_service.dart';
import '../../../../core/services/level_service.dart';
import '../../../../core/services/journey_time_service.dart';
import '../../../../data/local/hive_database.dart';
import '../../../../data/repositories/monthly_confession_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    
    _initialize();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    // 1. Fade the logo in
    _fadeCtrl.forward();
    
    // Hold minimum 2 seconds for aesthetic 
    final minimumHold = Future.delayed(const Duration(seconds: 2));

    // Background processing
    final backgroundTasks = Future(() async {
      // 1. DB Migration
      final prefs = getIt<SharedPreferences>();
      if (!(prefs.getBool('migrationV1Complete') ?? false)) {
        final confessRepo = getIt<MonthlyConfessionRepository>();
        final allConfessions = confessRepo.getAllConfessions();
        final zeros = allConfessions.where((c) => c.monthNumber == 0).toList();
        if (zeros.length > 1) {
          zeros.sort((a, b) => a.writtenAt.compareTo(b.writtenAt));
          for (int i = 1; i < zeros.length; i++) {
            await confessRepo.deleteConfession(zeros[i].confessionId);
          }
        }
        await prefs.setBool('migrationV1Complete', true);
      }

      // 2. Auto-close daily loop if journey explicitly started
      await getIt<DailyCheckInService>().runCheckOnLaunch();

      // 3. Evaluate levels
      if (HiveDatabase.journeyBox.isNotEmpty) {
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final currentDay = getIt<JourneyTimeService>().currentJourneyDay(nowMs);
        await getIt<LevelService>().evaluatePastDays(currentDay);

        // 4. Unlock confessions if journey is complete
        if (currentDay >= 365) {
          await getIt<MonthlyConfessionRepository>().unlockAllConfessions();
        }
      }
    });

    // Wait for everything
    await Future.wait([minimumHold, backgroundTasks]);

    // Fade out
    await _fadeCtrl.reverse();

    if (mounted) {
      if (HiveDatabase.journeyBox.isNotEmpty) {
        context.go(AppRoutes.dashboard);
      } else {
        context.go(AppRoutes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Explicit pure black
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: const Text(
            '365',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 64,
              fontWeight: AppFontWeight.extraBold,
              letterSpacing: 4.0,
            ),
          ),
        ),
      ),
    );
  }
}

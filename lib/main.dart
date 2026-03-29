import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/core.dart';
import 'core/router/app_router.dart';
import 'core/di/service_locator.dart';
import 'core/services/daily_check_in_service.dart';
import 'core/services/level_service.dart';
import 'core/services/journey_time_service.dart';
import 'data/local/hive_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/repositories/monthly_confession_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Lock to portrait ──────────────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Status bar / nav bar styling ─────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ── Hive initialization ──────────────────────────────────────────────────
  await HiveDatabase.init();

  // ── GetIt service locator ────────────────────────────────────────────────
  await ServiceLocator.setup();

  // ── Database Migration for Month 0 Reason Vaults ─────────────────────────
  // Moved to SplashScreen logic to ensure UI renders first.
  
  runApp(const Mirror365App());
}

class Mirror365App extends StatelessWidget {
  const Mirror365App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: AppRouter.router,
    );
  }
}

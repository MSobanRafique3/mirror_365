import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../../data/local/hive_database.dart';
import '../../features/onboarding/pages/onboarding_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/goals/pages/goals_page.dart';
import '../../features/goals/pages/goal_detail_page.dart';
import '../../features/timer/pages/timer_page.dart';
import '../../features/graphs/pages/graphs_page.dart';
import '../../features/levels/pages/levels_page.dart';
import '../../features/mirror/pages/mirror_page.dart';
import '../../features/final_five/pages/final_five_page.dart';

import '../../features/splash/screens/splash_screen.dart';
import '../../features/dashboard/pages/main_shell_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final hasJourney = HiveDatabase.journeyBox.isNotEmpty;
      final goingToOnboarding = state.matchedLocation == AppRoutes.onboarding;
      final goingToSplash = state.matchedLocation == AppRoutes.splash;

      // Splash allows anything because it handles redirection internally
      if (goingToSplash) return null;

      // If no journey exists and they're not already on onboarding → redirect
      if (!hasJourney && !goingToOnboarding) {
        return AppRoutes.onboarding;
      }
      // If journey exists and they somehow land on onboarding → go to dashboard
      if (hasJourney && goingToOnboarding) {
        return AppRoutes.dashboard;
      }
      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShellPage(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.goals,
            name: 'goals',
            builder: (context, state) => const GoalsPage(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                name: 'goal-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return GoalDetailPage(goalId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.graphs,
            name: 'graphs',
            builder: (context, state) => const GraphsPage(),
          ),
          GoRoute(
            path: AppRoutes.levels,
            name: 'levels',
            builder: (context, state) => const LevelsPage(),
          ),
        ],
      ),
      // Standalone outside the Shell
      GoRoute(
        path: AppRoutes.timer,
        name: 'timer',
        builder: (context, state) => const TimerPage(),
      ),
      GoRoute(
        path: AppRoutes.mirror,
        name: 'mirror',
        builder: (context, state) => const MirrorPage(),
      ),
      GoRoute(
        path: AppRoutes.finalFive,
        name: 'final-five',
        builder: (context, state) => const FinalFivePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          '404 — Page not found\n${state.error}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

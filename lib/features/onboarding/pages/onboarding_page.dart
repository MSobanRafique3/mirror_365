import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../screens/welcome_screen.dart';
import '../screens/rules_screen.dart';
import '../screens/goal_setup_screen.dart';
import '../screens/daily_goal_setup_screen.dart';
import '../screens/reason_vault_screen.dart';
import '../screens/final_confirmation_screen.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/user_journey_repository.dart';
import '../../../data/repositories/journey_goal_repository.dart';
import '../../../data/repositories/monthly_confession_repository.dart';
import '../../../core/constants/app_constants.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(
        journeyRepo: getIt<UserJourneyRepository>(),
        goalRepo: getIt<JourneyGoalRepository>(),
        confessionRepo: getIt<MonthlyConfessionRepository>(),
      ),
      child: const _OnboardingShell(),
    );
  }
}

class _OnboardingShell extends StatelessWidget {
  const _OnboardingShell();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      buildWhen: (prev, curr) => prev.step != curr.step,
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: AppDuration.slow,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(state.step),
            child: _screenFor(state.step),
          ),
        );
      },
    );
  }

  Widget _screenFor(OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        return const WelcomeScreen();
      case OnboardingStep.rules:
        return const RulesScreen();
      case OnboardingStep.yearlyGoals:
        return const YearlyGoalSetupScreen();
      case OnboardingStep.monthlyGoals:
        return const MonthlyGoalSetupScreen();
      case OnboardingStep.dailyGoals:
        return const DailyGoalSetupScreenFull();
      case OnboardingStep.reasonVault:
        return const ReasonVaultScreen();
      case OnboardingStep.finalConfirmation:
        return const FinalConfirmationScreen();
    }
  }
}

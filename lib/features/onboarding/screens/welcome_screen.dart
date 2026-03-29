import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_widgets.dart';
import '../../../core/constants/app_constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _fadeCtrl.forward();
        _slideCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // App name
              Text(
                'MIRROR 365',
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  fontSize: AppFontSize.sm,
                  fontWeight: AppFontWeight.bold,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Main headline
              const Text(
                '365 DAYS.\nNO EXCUSES.\nNO EDITS.\nNO MERCY.',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 34,
                  fontWeight: AppFontWeight.extraBold,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Thin gold accent line
              Container(
                width: 48,
                height: 2,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Subtext
              const Text(
                'This app is a mirror.\nIt will show you exactly who you are.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppFontSize.lg,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),

              const Spacer(flex: 3),

              OnboardingPrimaryButton(
                label: 'I AM READY',
                onPressed: () =>
                    context.read<OnboardingBloc>().add(const OnboardingNextStep()),
              ),

              const SizedBox(height: AppSpacing.md),

              const Center(
                child: Text(
                  'THERE IS NO UNDO',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: AppFontSize.xs,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

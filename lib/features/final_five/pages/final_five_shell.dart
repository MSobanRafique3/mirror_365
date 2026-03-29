import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/journey_time_service.dart';
import '../../../data/repositories/repositories.dart';
import '../bloc/final_five_bloc.dart';
import 'the_wound_screen.dart';
import 'the_peak_screen.dart';
import 'the_full_mirror_screen.dart';
import 'the_confessions_screen.dart';
import 'the_certificate_screen.dart';

class FinalFiveShell extends StatelessWidget {
  final int currentJourneyDay;

  const FinalFiveShell({super.key, required this.currentJourneyDay});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FinalFiveBloc(
        userRepo: getIt<UserJourneyRepository>(),
        dayRepo: getIt<DayRecordRepository>(),
        goalRepo: getIt<JourneyGoalRepository>(),
        entryRepo: getIt<GoalEntryRepository>(),
        confessRepo: getIt<MonthlyConfessionRepository>(),
        levelRepo: getIt<LevelRepository>(),
      )..add(FinalFiveLoadRequested(currentJourneyDay)),
      child: _FinalFiveView(currentDay: currentJourneyDay),
    );
  }
}

class _FinalFiveView extends StatefulWidget {
  final int currentDay;
  const _FinalFiveView({required this.currentDay});

  @override
  State<_FinalFiveView> createState() => _FinalFiveViewState();
}

class _FinalFiveViewState extends State<_FinalFiveView> with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Deep black required
      body: Stack(
        children: [
          // Background Particles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animCtrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _GoldParticlePainter(animationValue: _animCtrl.value),
                );
              },
            ),
          ),
          
          SafeArea(
            child: BlocBuilder<FinalFiveBloc, FinalFiveState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                // If dismissed, return a waiting shell
                if (state.isDismissed && widget.currentDay < 365) {
                  return const Center(
                    child: Text(
                      'AWAIT TOMORROW',
                      style: TextStyle(color: AppColors.textDisabled, fontSize: 18, letterSpacing: 4.0),
                    ),
                  );
                }

                // Day Selection
                Widget body;
                if (widget.currentDay == 361) {
                  body = const TheWoundScreen();
                } else if (widget.currentDay == 362) {
                  body = const ThePeakScreen();
                } else if (widget.currentDay == 363) {
                  body = const TheFullMirrorScreen();
                } else if (widget.currentDay == 364) {
                  body = const TheConfessionsScreen();
                } else {
                  body = const TheCertificateScreen();
                }

                return Column(
                  children: [
                    // GAUNTLET Progress Top Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'THE GAUNTLET',
                            style: TextStyle(color: AppColors.primary, fontWeight: AppFontWeight.bold, letterSpacing: 3.0),
                          ),
                          Text(
                            'DAY ${min(widget.currentDay, 365)} / 365',
                            style: const TextStyle(color: AppColors.textPrimary, letterSpacing: 1.5, fontWeight: AppFontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: body),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldParticlePainter extends CustomPainter {
  final double animationValue;
  final Random rand = Random(42); // Seeded for deterministic paths

  _GoldParticlePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.15) // subtle gold
      ..style = PaintingStyle.fill;

    // Draw 30 particles drifting upward slowly
    for (int i = 0; i < 30; i++) {
      final speed = rand.nextDouble() * 0.5 + 0.1;
      final startX = rand.nextDouble() * size.width;
      
      // Calculate Y position based on animation value pushing it linearly upwards
      double movingY = size.height - ((animationValue * size.height * speed * 2) % size.height);
      
      // Stagger vertical offsets artificially
      movingY = (movingY + rand.nextDouble() * size.height) % size.height;

      final radius = rand.nextDouble() * 2 + 1; // 1-3 px
      canvas.drawCircle(Offset(startX, movingY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoldParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../bloc/final_five_bloc.dart';

class ThePeakScreen extends StatelessWidget {
  const ThePeakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinalFiveBloc, FinalFiveState>(
      builder: (context, state) {
        final rec = state.bestDayRec;
        final completed = state.bestDayCompletedGoals;
        final dist = state.bestDayDistance;

        return GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
              context.read<FinalFiveBloc>().add(const FinalFiveScreenDismissed());
            }
          },
          child: Container(
            color: Colors.transparent, 
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                const Text(
                  'YOUR BEST DAY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppFontSize.xl,
                    letterSpacing: 4.0,
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                
                if (rec != null) ...[
                  Text(
                    'DAY ${rec.journeyDay}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 64,
                      letterSpacing: 2.0,
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    dist == 0 ? 'TODAY' : '$dist DAYS AGO',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: AppFontSize.md,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    '${(rec.overallCompletionRate * 100).toStringAsFixed(0)}% COMPLETION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: rec.isPure ? AppColors.primary : AppColors.textPrimary,
                      fontSize: AppFontSize.lg,
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                  if (rec.isPure) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const Text('PURE STATUS ACHIEVED', textAlign: TextAlign.center, style: TextStyle(color: AppColors.primary, letterSpacing: 2.0, fontSize: 10)),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  
                  if (completed.isNotEmpty) ...[
                    const Text(
                      'YOU CONQUERED:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        letterSpacing: 2.0,
                        fontSize: AppFontSize.sm,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...completed.map((g) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        g.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    )),
                  ],
                ] else ...[
                  const Text('NO DATA FOUND.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textDisabled)),
                ],
                
                const Spacer(),
                
                const Icon(Icons.keyboard_arrow_up, color: AppColors.textDisabled, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'SWIPE UP TO ACCEPT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    letterSpacing: 2.0,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }
}

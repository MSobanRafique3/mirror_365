import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../../../core/constants/app_constants.dart';

class SilencePenaltyScreen extends StatelessWidget {
  const SilencePenaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (p, c) => p.showSilencePenaltyOverlay != c.showSilencePenaltyOverlay,
      builder: (context, state) {
        if (!state.showSilencePenaltyOverlay) return const SizedBox.shrink();

        return Positioned.fill(
          child: GestureDetector(
            onTap: () => context
                .read<DashboardBloc>()
                .add(const DashboardSilencePenaltyDismissed()),
            child: Container(
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${state.failedGoalsCountDuringSilence}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 96,
                          fontWeight: AppFontWeight.extraBold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'GOALS FAILED\nWHILE YOU WERE GONE.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: AppFontSize.sm,
                          fontWeight: AppFontWeight.bold,
                          letterSpacing: 2.0,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xxl * 3),
                      
                      const Text(
                        'TAP ANYWHERE TO CONFRONT TODAY',
                        style: TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: AppFontSize.sm,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

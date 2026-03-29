import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../graphs/widgets/year_map_widget.dart';
import '../bloc/final_five_bloc.dart';

class TheFullMirrorScreen extends StatefulWidget {
  const TheFullMirrorScreen({super.key});

  @override
  State<TheFullMirrorScreen> createState() => _TheFullMirrorScreenState();
}

  bool _canDismiss = false;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollCtrl.hasClients) {
        if (_scrollCtrl.position.maxScrollExtent <= 0) {
          setState(() => _canDismiss = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll(ScrollMetrics metrics) {
    if (metrics.pixels >= metrics.maxScrollExtent - 20) {
      if (!_canDismiss) {
        setState(() => _canDismiss = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinalFiveBloc, FinalFiveState>(
      builder: (context, state) {
        return GestureDetector(
          onVerticalDragEnd: (details) {
            if (_canDismiss && details.primaryVelocity != null && details.primaryVelocity! < 0) {
              context.read<FinalFiveBloc>().add(const FinalFiveScreenDismissed());
            }
          },
          child: Container(
            color: Colors.transparent,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                _onScroll(notification.metrics);
                return false;
              },
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    const Text(
                      '360 DAYS.\nTHIS IS WHO YOU WERE.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: AppFontSize.xl,
                        letterSpacing: 4.0,
                        fontWeight: AppFontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl * 2),
                    
                    // The massive map
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      color: Colors.black, // contrast layer
                      child: YearMapWidget(yearMapDays: state.allDays),
                    ),
                    
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Below it
                    _StatRow(label: 'PURE DAYS', value: '${state.totalPureDays}', color: AppColors.primary),
                    _StatRow(label: 'FAILED DAYS', value: '${state.totalFailedDays}', color: AppColors.error),
                    _StatRow(label: 'GOAL OPERATIONS', value: '${state.totalGoalsCompleted} / ${state.totalGoalsPossible}', color: AppColors.textPrimary),
                    _StatRow(label: 'FINAL SCORE', value: '${(state.finalDisciplineScore * 100).toStringAsFixed(1)}%', color: AppColors.textPrimary),
                    
                    const SizedBox(height: AppSpacing.xxl * 2),
                    
                    if (_canDismiss) ...[
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
                    ] else ...[
                      const Text(
                        'SCROLL TO REVEAL ALL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          letterSpacing: 4.0,
                          fontSize: 10,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl * 2),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, letterSpacing: 2.0, fontSize: AppFontSize.sm)),
          Text(value, style: TextStyle(color: color, letterSpacing: 2.0, fontSize: AppFontSize.md, fontWeight: AppFontWeight.bold)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/models/models.dart';

class ReckoningDayScreen extends StatefulWidget {
  const ReckoningDayScreen({super.key});

  @override
  State<ReckoningDayScreen> createState() => _ReckoningDayScreenState();
}

class _ReckoningDayScreenState extends State<ReckoningDayScreen> {
  bool _isLoading = true;
  int _totalPure = 0;
  int _totalFailed = 0;
  int _bestStreak = 0;
  String _mostFailedGoal = '';
  String _mostConsistentGoal = '';
  String _improvementVelocity = '';
  String _brutalSentence = '';
  
  @override
  void initState() {
    super.initState();
    _calculateReckoningStats();
  }

  Future<void> _calculateReckoningStats() async {
    final dayRepo = getIt<DayRecordRepository>();
    final goalRepo = getIt<JourneyGoalRepository>();
    final entryRepo = getIt<GoalEntryRepository>();

    final allDays = dayRepo.getAllRecords();
    int currentStreak = 0;
    int maxStreak = 0;

    for (final d in allDays) {
      if (d.isPure) {
        _totalPure++;
        currentStreak++;
        if (currentStreak > maxStreak) maxStreak = currentStreak;
      } else {
        currentStreak = 0;
      }
      if (d.isFailed) _totalFailed++;
    }
    _bestStreak = maxStreak;

    // Goals breakdown
    final allGoals = goalRepo.getAllGoals();
    int minFails = 99999;
    int maxFails = -1;
    String bestGoalId = '';
    String worstGoalId = '';

    for (final g in allGoals) {
      final entries = entryRepo.getEntriesForGoal(g.goalId);
      int failCount = entries.where((e) => !e.isCompleted).length;
      
      if (failCount > maxFails) {
        maxFails = failCount;
        worstGoalId = g.goalId;
      }
      if (failCount < minFails && entries.isNotEmpty) {
        minFails = failCount;
        bestGoalId = g.goalId;
      }
    }

    _mostFailedGoal = allGoals.firstWhere((g) => g.goalId == worstGoalId, orElse: () => allGoals.first).title;
    _mostConsistentGoal = allGoals.firstWhere((g) => g.goalId == bestGoalId, orElse: () => allGoals.first).title;

    // Improvement Velocity (Rolling 7d vs preceding 7d)
    final dState = context.read<DashboardBloc>().state;
    final currentDay = dState.reckoningDayNumber;

    final last7 = allDays.where((r) => r.journeyDay >= currentDay - 7 && r.journeyDay < currentDay).toList();
    final prev7 = allDays.where((r) => r.journeyDay >= currentDay - 14 && r.journeyDay < currentDay - 7).toList();
    
    final lAvg = last7.isEmpty ? 0.0 : last7.fold<double>(0, (s, r) => s + r.overallCompletionRate) / last7.length;
    final pAvg = prev7.isEmpty ? 0.0 : prev7.fold<double>(0, (s, r) => s + r.overallCompletionRate) / prev7.length;
    
    final diff = lAvg - pAvg;
    if (diff > 0.05) {
      _improvementVelocity = 'IMPROVING';
    } else if (diff < -0.05) {
      _improvementVelocity = 'DECLINING';
    } else {
      _improvementVelocity = 'STAGNANT';
    }

    // Brutal Sentence
    final score = dState.overallScore;
    if (score > 0.8) {
      _brutalSentence = 'You are becoming who you said you would be. Do not stop.';
    } else if (score >= 0.5) {
      _brutalSentence = 'You are average. Average is a choice.';
    } else {
      _brutalSentence = 'You are failing yourself. The clock does not care.';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (p, c) => p.showReckoningScreen != c.showReckoningScreen,
      builder: (context, state) {
        if (!state.showReckoningScreen) return const SizedBox.shrink();

        if (_isLoading) {
          return Positioned.fill(
            child: Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: AppColors.primary))),
          );
        }

        final levelName = state.currentLevel?.levelName.toUpperCase() ?? 'RAW';
        final overallScoreStr = '${(state.overallScore * 100).toStringAsFixed(1)}%';

        return Positioned.fill(
          child: Container(
            color: Colors.black,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'DAY ${state.reckoningDayNumber} RECKONING.',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: AppFontSize.lg,
                        fontWeight: AppFontWeight.bold,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'FACE YOURSELF.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: AppFontSize.xl,
                        fontWeight: AppFontWeight.extraBold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.xxl * 1.5),
                    
                    Text(overallScoreStr, style: const TextStyle(color: AppColors.primary, fontSize: 64, fontWeight: AppFontWeight.bold, letterSpacing: 2.0)),
                    const Text('OVERALL DISCIPLINE SCORE', style: TextStyle(color: AppColors.textDisabled, fontSize: 10, letterSpacing: 2.0)),
                    
                    const SizedBox(height: AppSpacing.xxl),
                    
                    _StatRow(label: 'CURRENT RANK', value: levelName, color: AppColors.textPrimary),
                    _StatRow(label: 'TOTAL PURE DAYS', value: '$_totalPure', color: AppColors.primary),
                    _StatRow(label: 'TOTAL FAILED DAYS', value: '$_totalFailed', color: AppColors.error),
                    _StatRow(label: 'BEST STREAK', value: '$_bestStreak DAYS', color: AppColors.textPrimary),
                    _StatRow(label: 'VELOCITY (14d)', value: _improvementVelocity, color: _improvementVelocity == 'DECLINING' ? AppColors.error : AppColors.textPrimary),
                    
                    const SizedBox(height: AppSpacing.md),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: AppSpacing.md),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MOST CONSISTENT:', style: TextStyle(color: AppColors.textDisabled, fontSize: 10, letterSpacing: 1.5)),
                        const SizedBox(height: 2),
                        Text(_mostConsistentGoal.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontSize: AppFontSize.sm, letterSpacing: 1.0)),
                        const SizedBox(height: AppSpacing.md),
                        const Text('MOST ABANDONED:', style: TextStyle(color: AppColors.textDisabled, fontSize: 10, letterSpacing: 1.5)),
                        const SizedBox(height: 2),
                        Text(_mostFailedGoal.toUpperCase(), style: const TextStyle(color: AppColors.error, fontSize: AppFontSize.sm, letterSpacing: 1.0)),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      _brutalSentence,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: state.overallScore >= 0.5 ? AppColors.textPrimary : AppColors.error,
                        fontSize: AppFontSize.md,
                        height: 1.6,
                        letterSpacing: 1.0,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    GestureDetector(
                      onTap: () {
                        context.read<DashboardBloc>().add(const DashboardReckoningScreenDismissed());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'I HAVE FACED THIS',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: AppFontSize.md,
                            fontWeight: AppFontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
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
          Text(label, style: const TextStyle(color: AppColors.textDisabled, letterSpacing: 2.0, fontSize: 10)),
          Text(value, style: TextStyle(color: color, letterSpacing: 1.5, fontSize: AppFontSize.sm, fontWeight: AppFontWeight.bold)),
        ],
      ),
    );
  }
}

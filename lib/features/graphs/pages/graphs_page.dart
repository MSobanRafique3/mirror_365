import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/journey_time_service.dart';
import '../../../../data/repositories/repositories.dart';
import '../bloc/graphs_bloc.dart';
import '../widgets/year_map_widget.dart';
import '../widgets/daily_discipline_chart_widget.dart';
import '../widgets/weekly_rhythm_chart_widget.dart';
import '../widgets/goal_breakdown_list_widget.dart';
import '../widgets/improvement_velocity_widget.dart';
import '../widgets/honest_mirror_chart_widget.dart';

class GraphsPage extends StatelessWidget {
  const GraphsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GraphsBloc(
        dayRepo: getIt<DayRecordRepository>(),
        goalRepo: getIt<JourneyGoalRepository>(),
        entryRepo: getIt<GoalEntryRepository>(),
        timeService: getIt<JourneyTimeService>(),
        prefs: getIt<SharedPreferences>(),
      )..add(const GraphsLoadRequested()),
      child: const _GraphsView(),
    );
  }
}

class _GraphsView extends StatelessWidget {
  const _GraphsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANALYTICS & DATA', style: TextStyle(color: AppColors.primary, letterSpacing: 2.0)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocBuilder<GraphsBloc, GraphsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Year Map
                YearMapWidget(yearMapDays: state.yearMapDays),
                const SizedBox(height: AppSpacing.xxl),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppSpacing.xl),

                // 2. Daily Discipline 
                DailyDisciplineChartWidget(
                  last30Days: state.last30Days,
                  personalLifetimeAverage: state.personalLifetimeAverage,
                ),
                const SizedBox(height: AppSpacing.xxl),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppSpacing.xl),

                // 3. Weekly Rhythm
                WeeklyRhythmChartWidget(
                  weekdayAverages: state.weekdayAverages,
                  weakestWeekday: state.weakestWeekday,
                ),
                const SizedBox(height: AppSpacing.xxl),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppSpacing.xl),

                // 4. Goal Breakdown
                GoalBreakdownListWidget(goalBreakdowns: state.goalBreakdowns),
                const SizedBox(height: AppSpacing.xxl),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppSpacing.xl),

                // 5. Improvement Velocity
                ImprovementVelocityWidget(
                  velocitySeries: state.velocitySeries,
                  comfortZoneWarning: state.comfortZoneWarning,
                ),
                const SizedBox(height: AppSpacing.xxl),
                
                // 6. Honest Mirror
                if (state.honestMirrorUnlocked) ...[
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: AppSpacing.xl),
                  HonestMirrorChartWidget(
                    records: state.yearMapDays,
                    flashMirror: state.shouldFlashMirror,
                    onFlashComplete: () {
                      context.read<GraphsBloc>().add(const GraphsMirrorFlashed());
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

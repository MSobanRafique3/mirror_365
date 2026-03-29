import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/repositories/repositories.dart';
import '../../../data/models/journey_goal_model.dart';
import '../../../core/services/journey_time_service.dart';
import '../bloc/goals_bloc.dart';
import '../widgets/goal_card.dart';
import '../widgets/add_goal_bottom_sheet.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GoalsBloc(
        goalRepo: getIt<JourneyGoalRepository>(),
        entryRepo: getIt<GoalEntryRepository>(),
        timeService: getIt<JourneyTimeService>(),
      )..add(const GoalsLoadRequested()),
      child: const _GoalsView(),
    );
  }
}

class _GoalsView extends StatefulWidget {
  const _GoalsView();

  @override
  State<_GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<_GoalsView> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _openAddGoal(BuildContext context) {
    // Determine category from active tab
    final GoalCategory cat;
    switch (_tabCtrl.index) {
      case 1:
        cat = GoalCategory.monthly;
        break;
      case 2:
        cat = GoalCategory.yearly;
        break;
      case 0:
      default:
        cat = GoalCategory.daily;
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => AddGoalBottomSheet(initialCategory: cat),
    ).then((_) {
      // Refresh list after add
      if (context.mounted) {
        context.read<GoalsBloc>().add(const GoalsLoadRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GOALS', style: TextStyle(color: AppColors.primary, letterSpacing: 2.0)),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _openAddGoal(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textDisabled,
          labelStyle: const TextStyle(fontWeight: AppFontWeight.bold, letterSpacing: 1.0, fontSize: AppFontSize.xs),
          tabs: const [
            Tab(text: 'DAILY'),
            Tab(text: 'MONTHLY'),
            Tab(text: 'YEARLY'),
          ],
        ),
      ),
      body: BlocBuilder<GoalsBloc, GoalsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return TabBarView(
            controller: _tabCtrl,
            children: [
              _GoalList(dataList: state.dailyGoals, category: GoalCategory.daily),
              _GoalList(dataList: state.monthlyGoals, category: GoalCategory.monthly),
              _GoalList(dataList: state.yearlyGoals, category: GoalCategory.yearly),
            ],
          );
        },
      ),
    );
  }
}

class _GoalList extends StatelessWidget {
  final List<GoalCardData> dataList;
  final GoalCategory category;

  const _GoalList({required this.dataList, required this.category});

  @override
  Widget build(BuildContext context) {
    if (dataList.isEmpty) {
      return Center(
        child: Text(
          'NO ${category.name.toUpperCase()} GOALS.',
          style: const TextStyle(color: AppColors.textDisabled, letterSpacing: 2.0),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return GoalCard(data: dataList[index]);
      },
    );
  }
}

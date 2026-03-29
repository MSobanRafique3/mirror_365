import 'package:equatable/equatable.dart';
import '../../../data/models/journey_goal_model.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  
  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

class DashboardFaceTodayClicked extends DashboardEvent {
  const DashboardFaceTodayClicked();
}

class DashboardSilencePenaltyDismissed extends DashboardEvent {
  const DashboardSilencePenaltyDismissed();
}

class DashboardReckoningScreenDismissed extends DashboardEvent {
  const DashboardReckoningScreenDismissed();
}

class DashboardReasonVaultDismissed extends DashboardEvent {
  const DashboardReasonVaultDismissed();
}

class DashboardDailyGoalToggled extends DashboardEvent {
  final String goalId;
  const DashboardDailyGoalToggled(this.goalId);

  @override
  List<Object?> get props => [goalId];
}

class DashboardAddGoalRequested extends DashboardEvent {
  final GoalCategory category;
  final String title;
  final String description;
  final String targetValue;

  const DashboardAddGoalRequested({
    required this.category,
    required this.title,
    required this.description,
    required this.targetValue,
  });

  @override
  List<Object?> get props => [category, title, description, targetValue];
}

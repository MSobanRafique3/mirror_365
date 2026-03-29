import 'package:equatable/equatable.dart';

abstract class GoalsEvent extends Equatable {
  const GoalsEvent();

  @override
  List<Object?> get props => [];
}

class GoalsLoadRequested extends GoalsEvent {
  const GoalsLoadRequested();
}

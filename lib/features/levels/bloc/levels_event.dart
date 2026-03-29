import 'package:equatable/equatable.dart';

abstract class LevelsEvent extends Equatable {
  const LevelsEvent();

  @override
  List<Object?> get props => [];
}

class LevelsLoadRequested extends LevelsEvent {
  const LevelsLoadRequested();
}

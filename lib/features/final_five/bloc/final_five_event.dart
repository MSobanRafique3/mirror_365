import 'package:equatable/equatable.dart';

abstract class FinalFiveEvent extends Equatable {
  const FinalFiveEvent();

  @override
  List<Object?> get props => [];
}

class FinalFiveLoadRequested extends FinalFiveEvent {
  final int currentJourneyDay;
  const FinalFiveLoadRequested(this.currentJourneyDay);

  @override
  List<Object?> get props => [currentJourneyDay];
}

class FinalFiveScreenDismissed extends FinalFiveEvent {
  const FinalFiveScreenDismissed();
}

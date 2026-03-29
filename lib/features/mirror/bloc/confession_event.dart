import 'package:equatable/equatable.dart';

abstract class ConfessionEvent extends Equatable {
  const ConfessionEvent();

  @override
  List<Object?> get props => [];
}

class ConfessionLoadRequested extends ConfessionEvent {
  const ConfessionLoadRequested();
}

class ConfessionSubmitted extends ConfessionEvent {
  final String text;
  const ConfessionSubmitted(this.text);

  @override
  List<Object?> get props => [text];
}

import 'package:equatable/equatable.dart';

abstract class GraphsEvent extends Equatable {
  const GraphsEvent();

  @override
  List<Object?> get props => [];
}

class GraphsLoadRequested extends GraphsEvent {
  const GraphsLoadRequested();
}

class GraphsMirrorFlashed extends GraphsEvent {
  const GraphsMirrorFlashed();
}

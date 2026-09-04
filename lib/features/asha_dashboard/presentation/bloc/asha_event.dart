import 'package:equatable/equatable.dart';

abstract class AshaEvent extends Equatable {
  const AshaEvent();
  @override
  List<Object?> get props => [];
}

class AshaDashboardLoadRequested extends AshaEvent {
  const AshaDashboardLoadRequested();
}

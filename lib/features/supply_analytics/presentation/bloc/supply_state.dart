import 'package:equatable/equatable.dart';
import '../../data/supply_datasource.dart';

abstract class SupplyState extends Equatable {
  const SupplyState();
  @override
  List<Object?> get props => [];
}

class SupplyInitial extends SupplyState {
  const SupplyInitial();
}

class SupplyLoading extends SupplyState {
  const SupplyLoading();
}

class SupplyLoaded extends SupplyState {
  final SupplyAnalytics analytics;
  const SupplyLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

class SupplyError extends SupplyState {
  final String message;
  const SupplyError(this.message);

  @override
  List<Object?> get props => [message];
}

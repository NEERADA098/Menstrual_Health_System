import 'package:equatable/equatable.dart';
import '../../domain/entities/cycle_entity.dart';

abstract class CycleState extends Equatable {
  const CycleState();

  @override
  List<Object?> get props => [];
}

class CycleInitial extends CycleState {
  const CycleInitial();
}

class CycleLoading extends CycleState {
  const CycleLoading();
}

class CycleLoaded extends CycleState {
  final List<CycleEntity> history;
  final CycleEntity? currentCycle;
  final int? currentCycleDay;
  final int? predictedDaysUntilNextPeriod;
  final int averageCycleLength;

  const CycleLoaded({
    required this.history,
    this.currentCycle,
    this.currentCycleDay,
    this.predictedDaysUntilNextPeriod,
    required this.averageCycleLength,
  });

  @override
  List<Object?> get props => [
        history,
        currentCycle,
        currentCycleDay,
        predictedDaysUntilNextPeriod,
        averageCycleLength,
      ];
}

class CycleError extends CycleState {
  final String message;
  const CycleError(this.message);

  @override
  List<Object?> get props => [message];
}
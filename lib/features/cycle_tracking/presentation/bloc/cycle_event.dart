import 'package:equatable/equatable.dart';
import '../../domain/entities/cycle_entity.dart';

abstract class CycleEvent extends Equatable {
  const CycleEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the home/calendar screen first loads
class CycleLoadRequested extends CycleEvent {
  final String userId;
  const CycleLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Fired when user taps "Log Period" and confirms
class CycleLogRequested extends CycleEvent {
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final FlowIntensity? flowIntensity;
  final String? notes;

  const CycleLogRequested({
    required this.userId,
    required this.startDate,
    this.endDate,
    this.flowIntensity,
    this.notes,
  });

  @override
  List<Object?> get props =>
      [userId, startDate, endDate, flowIntensity, notes];
}
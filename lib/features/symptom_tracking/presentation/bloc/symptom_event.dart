import 'package:equatable/equatable.dart';
import '../../domain/entities/symptom_entity.dart';

abstract class SymptomEvent extends Equatable {
  const SymptomEvent();
  @override
  List<Object?> get props => [];
}

class SymptomLoadRequested extends SymptomEvent {
  final String userId;
  const SymptomLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class SymptomLogRequested extends SymptomEvent {
  final String userId;
  final DateTime logDate;
  final SymptomType symptomType;
  final SymptomSeverity severity;
  final String? notes;

  const SymptomLogRequested({
    required this.userId,
    required this.logDate,
    required this.symptomType,
    required this.severity,
    this.notes,
  });

  @override
  List<Object?> get props =>
      [userId, logDate, symptomType, severity, notes];
}

class SymptomDeleteRequested extends SymptomEvent {
  final String symptomId;
  final String userId;
  const SymptomDeleteRequested({
    required this.symptomId,
    required this.userId,
  });
  @override
  List<Object?> get props => [symptomId, userId];
}

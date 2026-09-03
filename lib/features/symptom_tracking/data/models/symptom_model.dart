import '../../domain/entities/symptom_entity.dart';

class SymptomModel extends SymptomEntity {
  const SymptomModel({
    required super.id,
    required super.userId,
    required super.logDate,
    required super.symptomType,
    required super.severity,
    super.notes,
    required super.createdAt,
    super.isSynced = false,
  });

  factory SymptomModel.fromMap(Map<String, dynamic> map) {
    return SymptomModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      logDate: DateTime.parse(map['log_date'] as String),
      symptomType: _typeFromString(map['symptom_type'] as String),
      severity: _severityFromString(map['severity'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      isSynced: (map['is_synced'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'log_date': logDate.toIso8601String(),
      'symptom_type': symptomType.name,
      'severity': severity.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
    };
  }

  static SymptomType _typeFromString(String value) {
    return SymptomType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SymptomType.cramps,
    );
  }

  static SymptomSeverity _severityFromString(String value) {
    return SymptomSeverity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SymptomSeverity.mild,
    );
  }
}

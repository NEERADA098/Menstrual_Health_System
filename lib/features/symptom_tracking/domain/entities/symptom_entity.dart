// CLINICAL BASIS: Symptom taxonomy validated by gynecologist consultation.
// Severity scale based on functional impact (affects daily activities)
// rather than numeric pain scale — more appropriate for low-literacy users.

enum SymptomType {
  // Pain symptoms
  cramps,
  backPain,
  headache,

  // Physical symptoms
  bloating,
  breastTenderness,
  nausea,
  fatigue,
  dizziness,

  // Skin/appearance (also PCOS indicators)
  acne,
  facialHair,

  // Mood symptoms
  moodSwings,
  anxiety,
  irritability,
}

// CLINICAL BASIS: Three-tier functional impact scale per gynecologist.
// "Does it stop you from daily activities?" is the key question.
enum SymptomSeverity { mild, moderate, severe }

class SymptomEntity {
  final String id;
  final String userId;
  final DateTime logDate;
  final SymptomType symptomType;
  final SymptomSeverity severity;
  final String? notes;
  final DateTime createdAt;
  final bool isSynced;

  const SymptomEntity({
    required this.id,
    required this.userId,
    required this.logDate,
    required this.symptomType,
    required this.severity,
    this.notes,
    required this.createdAt,
    this.isSynced = false,
  });

  SymptomEntity copyWith({
    String? id,
    String? userId,
    DateTime? logDate,
    SymptomType? symptomType,
    SymptomSeverity? severity,
    String? notes,
    DateTime? createdAt,
    bool? isSynced,
  }) {
    return SymptomEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      logDate: logDate ?? this.logDate,
      symptomType: symptomType ?? this.symptomType,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/symptom_entity.dart';
import '../repositories/symptom_repository.dart';

class LogSymptomParams {
  final String userId;
  final DateTime logDate;
  final SymptomType symptomType;
  final SymptomSeverity severity;
  final String? notes;

  const LogSymptomParams({
    required this.userId,
    required this.logDate,
    required this.symptomType,
    required this.severity,
    this.notes,
  });
}

class LogSymptom implements UseCase<SymptomEntity, LogSymptomParams> {
  final SymptomRepository repository;
  LogSymptom(this.repository);

  @override
  Future<Either<Failure, SymptomEntity>> call(LogSymptomParams params) {
    return repository.logSymptom(
      userId: params.userId,
      logDate: params.logDate,
      symptomType: params.symptomType,
      severity: params.severity,
      notes: params.notes,
    );
  }
}

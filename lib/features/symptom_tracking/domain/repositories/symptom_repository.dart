import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/symptom_entity.dart';

abstract class SymptomRepository {
  Future<Either<Failure, SymptomEntity>> logSymptom({
    required String userId,
    required DateTime logDate,
    required SymptomType symptomType,
    required SymptomSeverity severity,
    String? notes,
  });

  Future<Either<Failure, List<SymptomEntity>>> getSymptomsForUser(
    String userId,
  );

  Future<Either<Failure, List<SymptomEntity>>> getSymptomsForDate(
    String userId,
    DateTime date,
  );

  Future<Either<Failure, void>> deleteSymptom(String id);
}

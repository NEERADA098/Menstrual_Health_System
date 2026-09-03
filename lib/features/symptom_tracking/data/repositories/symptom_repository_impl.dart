import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/symptom_entity.dart';
import '../../domain/repositories/symptom_repository.dart';
import '../datasources/symptom_local_datasource.dart';

class SymptomRepositoryImpl implements SymptomRepository {
  final SymptomLocalDataSource _localDataSource;

  SymptomRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, SymptomEntity>> logSymptom({
    required String userId,
    required DateTime logDate,
    required SymptomType symptomType,
    required SymptomSeverity severity,
    String? notes,
  }) async {
    try {
      final symptom = await _localDataSource.insertSymptom(
        userId: userId,
        logDate: logDate,
        symptomType: symptomType,
        severity: severity,
        notes: notes,
      );
      return Right(symptom);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save symptom: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SymptomEntity>>> getSymptomsForUser(
    String userId,
  ) async {
    try {
      final symptoms = await _localDataSource.getSymptomsForUser(userId);
      return Right(symptoms);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load symptoms: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SymptomEntity>>> getSymptomsForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final symptoms =
          await _localDataSource.getSymptomsForDate(userId, date);
      return Right(symptoms);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load symptoms for date: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSymptom(String id) async {
    try {
      await _localDataSource.deleteSymptom(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete symptom: $e'));
    }
  }
}

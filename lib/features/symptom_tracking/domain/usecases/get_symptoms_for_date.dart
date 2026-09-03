import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/symptom_entity.dart';
import '../repositories/symptom_repository.dart';

class GetSymptomsByDateParams {
  final String userId;
  final DateTime date;
  const GetSymptomsByDateParams({required this.userId, required this.date});
}

class GetSymptomsForDate
    implements UseCase<List<SymptomEntity>, GetSymptomsByDateParams> {
  final SymptomRepository repository;
  GetSymptomsForDate(this.repository);

  @override
  Future<Either<Failure, List<SymptomEntity>>> call(
    GetSymptomsByDateParams params,
  ) {
    return repository.getSymptomsForDate(params.userId, params.date);
  }
}

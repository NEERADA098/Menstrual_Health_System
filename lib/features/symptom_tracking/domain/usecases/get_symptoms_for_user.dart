import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/symptom_entity.dart';
import '../repositories/symptom_repository.dart';

class GetSymptomsForUser implements UseCase<List<SymptomEntity>, String> {
  final SymptomRepository repository;
  GetSymptomsForUser(this.repository);

  @override
  Future<Either<Failure, List<SymptomEntity>>> call(String userId) {
    return repository.getSymptomsForUser(userId);
  }
}

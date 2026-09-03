import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// UseCase - The base contract every business action must follow.
///
/// WHY THIS EXISTS:
/// Every single action a user can take (sign in, verify OTP, log a
/// period, request pads) is a "use case." By forcing every use case
/// to implement this same shape, your entire codebase becomes
/// predictable: call execute(), get back Either<Failure, Result>.
///
/// Type parameters explained:
/// - Type: what this use case RETURNS on success (e.g., UserEntity)
/// - Params: what this use case NEEDS as input (e.g., phone number)
abstract class UseCase<Output, Params> {
  /// Every use case must implement call() - this is what makes
  /// the class "callable" like a function: myUseCase(params)
  Future<Either<Failure, Output>> call(Params params);
}

/// NoParams - Used when a use case needs NO input.
/// Example: signOut() doesn't need any parameters.
class NoParams {
  const NoParams();
}

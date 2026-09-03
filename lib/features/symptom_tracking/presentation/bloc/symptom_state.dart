import 'package:equatable/equatable.dart';
import '../../domain/entities/symptom_entity.dart';

abstract class SymptomState extends Equatable {
  const SymptomState();
  @override
  List<Object?> get props => [];
}

class SymptomInitial extends SymptomState {
  const SymptomInitial();
}

class SymptomLoading extends SymptomState {
  const SymptomLoading();
}

class SymptomLoaded extends SymptomState {
  final List<SymptomEntity> symptoms;
  const SymptomLoaded(this.symptoms);
  @override
  List<Object?> get props => [symptoms];
}

class SymptomError extends SymptomState {
  final String message;
  const SymptomError(this.message);
  @override
  List<Object?> get props => [message];
}

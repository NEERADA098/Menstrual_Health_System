import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/log_symptom.dart';
import '../../domain/usecases/get_symptoms_for_user.dart';
import 'symptom_event.dart';
import 'symptom_state.dart';

class SymptomBloc extends Bloc<SymptomEvent, SymptomState> {
  final LogSymptom logSymptom;
  final GetSymptomsForUser getSymptomsForUser;

  SymptomBloc({
    required this.logSymptom,
    required this.getSymptomsForUser,
  }) : super(const SymptomInitial()) {
    on<SymptomLoadRequested>(_onLoadRequested);
    on<SymptomLogRequested>(_onLogRequested);
  }

  Future<void> _onLoadRequested(
    SymptomLoadRequested event,
    Emitter<SymptomState> emit,
  ) async {
    emit(const SymptomLoading());
    final result = await getSymptomsForUser(event.userId);
    result.fold(
      (failure) => emit(SymptomError(failure.message)),
      (symptoms) => emit(SymptomLoaded(symptoms)),
    );
  }

  Future<void> _onLogRequested(
    SymptomLogRequested event,
    Emitter<SymptomState> emit,
  ) async {
    emit(const SymptomLoading());
    final result = await logSymptom(LogSymptomParams(
      userId: event.userId,
      logDate: event.logDate,
      symptomType: event.symptomType,
      severity: event.severity,
      notes: event.notes,
    ));
    result.fold(
      (failure) => emit(SymptomError(failure.message)),
      (_) => add(SymptomLoadRequested(event.userId)),
    );
  }
}

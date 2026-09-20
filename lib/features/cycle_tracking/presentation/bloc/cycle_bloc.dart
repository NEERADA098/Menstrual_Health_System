import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/cycle_entity.dart';
import '../../domain/usecases/log_cycle.dart';
import '../../domain/usecases/get_cycle_history.dart';
import '../../domain/usecases/get_current_cycle.dart';
import 'cycle_event.dart';
import 'cycle_state.dart';

class CycleBloc extends Bloc<CycleEvent, CycleState> {
  final LogCycle logCycle;
  final GetCycleHistory getCycleHistory;
  final GetCurrentCycle getCurrentCycle;
  final Dio _dio;

  CycleBloc({
    required this.logCycle,
    required this.getCycleHistory,
    required this.getCurrentCycle,
  })  : _dio = Dio(BaseOptions(
          baseUrl: 'http://10.0.2.2:8000/api/v1',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        super(const CycleInitial()) {
    on<CycleLoadRequested>(_onLoadRequested);
    on<CycleLogRequested>(_onLogRequested);
  }

  Future<void> _onLoadRequested(
    CycleLoadRequested event,
    Emitter<CycleState> emit,
  ) async {
    emit(const CycleLoading());
    await _loadAndEmit(event.userId, emit);
  }

  Future<void> _onLogRequested(
    CycleLogRequested event,
    Emitter<CycleState> emit,
  ) async {
    emit(const CycleLoading());

    final result = await logCycle(LogCycleParams(
      userId: event.userId,
      startDate: event.startDate,
      endDate: event.endDate,
      flowIntensity: event.flowIntensity,
      notes: event.notes,
    ));

    final failed = result.fold((failure) => true, (_) => false);
    if (failed) {
      result.fold(
        (failure) => emit(CycleError(failure.message)),
        (_) => null,
      );
      return;
    }

    await _loadAndEmit(event.userId, emit);
  }

  Future<void> _loadAndEmit(String userId, Emitter<CycleState> emit) async {
    final historyResult = await getCycleHistory(userId);
    final currentResult = await getCurrentCycle(userId);

    final history = historyResult.fold(
      (failure) => <CycleEntity>[],
      (list) => list,
    );

    final current = currentResult.fold(
      (failure) => null,
      (cycle) => cycle,
    );

    final currentDay = _calculateCurrentCycleDay(current);

    // Try LSTM prediction from FastAPI first
    double? predictedDays;
    int avgLength = 28;
    String predictionMethod = 'default';

    try {
      final response = await _dio.get('/predict/$userId');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        predictedDays = (data['predicted_days'] as num).toDouble();
        avgLength = predictedDays.round();
        predictionMethod = data['method'] as String;
        debugPrint(
          'Prediction: $predictedDays days via $predictionMethod'
        );
      }
    } catch (e) {
      // Fallback to local average if API unavailable
      debugPrint('Prediction API unavailable, using local average: $e');
      avgLength = _calculateAverageCycleLength(history);
      predictedDays = _calculateDaysUntilNextPeriod(current, avgLength)
          ?.toDouble();
    }

    final daysUntilNext = current != null && avgLength > 0
        ? current.startDate
            .add(Duration(days: avgLength))
            .difference(DateTime.now())
            .inDays
        : null;

    emit(CycleLoaded(
      history: history,
      currentCycle: current,
      currentCycleDay: currentDay,
      predictedDaysUntilNextPeriod: daysUntilNext,
      averageCycleLength: avgLength,
    ));
  }

  int _calculateAverageCycleLength(List<CycleEntity> history) {
    if (history.length < 2) return 28;
    final sorted = [...history]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final gaps = <int>[];
    for (var i = 1; i < sorted.length; i++) {
      final gap =
          sorted[i].startDate.difference(sorted[i - 1].startDate).inDays;
      if (gap > 0 && gap < 90) gaps.add(gap);
    }
    if (gaps.isEmpty) return 28;
    return (gaps.reduce((a, b) => a + b) / gaps.length).round();
  }

  int? _calculateCurrentCycleDay(CycleEntity? current) {
    if (current == null) return null;
    return DateTime.now().difference(current.startDate).inDays + 1;
  }

  int? _calculateDaysUntilNextPeriod(CycleEntity? current, int avgLength) {
    if (current == null) return null;
    final predicted = current.startDate.add(Duration(days: avgLength));
    return predicted.difference(DateTime.now()).inDays;
  }
}

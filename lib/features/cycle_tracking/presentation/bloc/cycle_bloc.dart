import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cycle_entity.dart';
import '../../domain/usecases/log_cycle.dart';
import '../../domain/usecases/get_cycle_history.dart';
import '../../domain/usecases/get_current_cycle.dart';
import 'cycle_event.dart';
import 'cycle_state.dart';

/// CycleBloc - Orchestrates cycle data and computes the SIMPLE
/// placeholder prediction (basic average of past cycles).
///
/// IMPORTANT: This is intentionally basic. Phase 9 will replace the
/// _calculatePrediction() logic with a real LSTM model call, but
/// because that swap happens entirely INSIDE this one method, the
/// UI screens built in this phase will need ZERO changes later.
/// This is Clean Architecture paying off concretely.
class CycleBloc extends Bloc<CycleEvent, CycleState> {
  final LogCycle logCycle;
  final GetCycleHistory getCycleHistory;
  final GetCurrentCycle getCurrentCycle;

  CycleBloc({
    required this.logCycle,
    required this.getCycleHistory,
    required this.getCurrentCycle,
  }) : super(const CycleInitial()) {
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

    // Reload everything fresh after a successful log
    await _loadAndEmit(event.userId, emit);
  }

  /// Shared logic: fetch history + current cycle, compute prediction,
  /// emit one combined CycleLoaded state.
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

    final avgLength = _calculateAverageCycleLength(history);
    final currentDay = _calculateCurrentCycleDay(current);
    final daysUntilNext = _calculateDaysUntilNextPeriod(current, avgLength);

    emit(CycleLoaded(
      history: history,
      currentCycle: current,
      currentCycleDay: currentDay,
      predictedDaysUntilNextPeriod: daysUntilNext,
      averageCycleLength: avgLength,
    ));
  }

  /// PLACEHOLDER PREDICTION LOGIC - replaced by LSTM in Phase 9.
  /// Simple average of the gaps between recorded period start dates.
  int _calculateAverageCycleLength(List<CycleEntity> history) {
    if (history.length < 2) return 28; // Medical default fallback

    // History is sorted most-recent-first (from the repository query)
    final sorted = [...history]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final gaps = <int>[];
    for (var i = 1; i < sorted.length; i++) {
      final gap =
          sorted[i].startDate.difference(sorted[i - 1].startDate).inDays;
      if (gap > 0 && gap < 90) gaps.add(gap); // Sanity filter
    }

    if (gaps.isEmpty) return 28;
    return (gaps.reduce((a, b) => a + b) / gaps.length).round();
  }

  int? _calculateCurrentCycleDay(CycleEntity? current) {
    if (current == null) return null;
    final daysSinceStart = DateTime.now().difference(current.startDate).inDays;
    return daysSinceStart + 1; // Day 1 is the start date itself
  }

  int? _calculateDaysUntilNextPeriod(CycleEntity? current, int avgLength) {
    if (current == null) return null;
    final predictedNextStart = current.startDate.add(Duration(days: avgLength));
    final daysUntil = predictedNextStart.difference(DateTime.now()).inDays;
    return daysUntil;
  }
}

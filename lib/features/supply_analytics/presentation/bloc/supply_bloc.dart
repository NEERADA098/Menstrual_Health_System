import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/supply_datasource.dart';
import 'supply_event.dart';
import 'supply_state.dart';

class SupplyBloc extends Bloc<SupplyEvent, SupplyState> {
  final SupplyDataSource _dataSource;

  SupplyBloc({SupplyDataSource? dataSource})
      : _dataSource = dataSource ?? SupplyDataSource(),
        super(const SupplyInitial()) {
    on<SupplyLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    SupplyLoadRequested event,
    Emitter<SupplyState> emit,
  ) async {
    emit(const SupplyLoading());
    try {
      final analytics = await _dataSource.getAnalytics();
      emit(SupplyLoaded(analytics));
    } catch (e) {
      emit(SupplyError(e.toString()));
    }
  }
}

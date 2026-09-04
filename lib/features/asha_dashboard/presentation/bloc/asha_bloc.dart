import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/asha_remote_datasource.dart';
import 'asha_event.dart';
import 'asha_state.dart';

class AshaBloc extends Bloc<AshaEvent, AshaState> {
  final AshaRemoteDataSource _dataSource;

  AshaBloc({AshaRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? AshaRemoteDataSource(),
        super(const AshaInitial()) {
    on<AshaDashboardLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    AshaDashboardLoadRequested event,
    Emitter<AshaState> emit,
  ) async {
    emit(const AshaLoading());
    try {
      final summary = await _dataSource.getCommunityummary();
      final flaggedUsers = await _dataSource.getFlaggedUsers();
      emit(AshaLoaded(summary: summary, flaggedUsers: flaggedUsers));
    } catch (e) {
      emit(AshaError(e.toString()));
    }
  }
}

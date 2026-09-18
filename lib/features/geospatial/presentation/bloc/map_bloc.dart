import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/location_datasource.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationDataSource _dataSource;

  MapBloc({LocationDataSource? dataSource})
      : _dataSource = dataSource ?? LocationDataSource(),
        super(const MapInitial()) {
    on<MapLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    MapLoadRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    try {
      double? userLat;
      double? userLng;

      final permission = await Geolocator.checkPermission();
      final granted = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (granted) {
        try {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          ).timeout(const Duration(seconds: 10));
          userLat = position.latitude;
          userLng = position.longitude;
        } catch (_) {
          // GPS timed out or unavailable — continue without location
        }
      }

      List<LocationModel> locations;

      if (userLat != null && userLng != null) {
        locations = await _dataSource.getNearbyLocations(
          lat: userLat,
          lng: userLng,
          radiusKm: 50.0,
        );
      } else {
        locations = await _dataSource.getAllLocations();
      }

      emit(MapLoaded(
        locations: locations,
        userLat: userLat,
        userLng: userLng,
      ));
    } catch (e) {
      try {
        final locations = await _dataSource.getAllLocations();
        emit(MapLoaded(locations: locations));
      } catch (e2) {
        emit(MapError(e2.toString()));
      }
    }
  }
}

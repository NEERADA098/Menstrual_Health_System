import 'package:equatable/equatable.dart';
import '../../data/location_datasource.dart';

abstract class MapState extends Equatable {
  const MapState();
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  final List<LocationModel> locations;
  final double? userLat;
  final double? userLng;

  const MapLoaded({
    required this.locations,
    this.userLat,
    this.userLng,
  });

  @override
  List<Object?> get props => [locations, userLat, userLng];
}

class MapError extends MapState {
  final String message;
  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}

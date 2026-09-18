import 'package:equatable/equatable.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => [];
}

class MapLoadRequested extends MapEvent {
  const MapLoadRequested();
}

class MapLocationUpdated extends MapEvent {
  final double latitude;
  final double longitude;

  const MapLocationUpdated({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

import 'package:dio/dio.dart';

class LocationModel {
  final String id;
  final String name;
  final String locationType;
  final double latitude;
  final double longitude;
  final String? address;
  final double? distanceKm;

  const LocationModel({
    required this.id,
    required this.name,
    required this.locationType,
    required this.latitude,
    required this.longitude,
    this.address,
    this.distanceKm,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      locationType: json['location_type'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
    );
  }
}

class LocationDataSource {
  final Dio _dio;

  LocationDataSource()
      : _dio = Dio(BaseOptions(
          baseUrl: 'http://localhost:8000/api/v1',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));

  Future<List<LocationModel>> getNearbyLocations({
    required double lat,
    required double lng,
    double radiusKm = 50.0,
  }) async {
    final response = await _dio.get(
      '/locations/nearby',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius_km': radiusKm,
      },
    );
    final list = response.data as List;
    return list.map((e) => LocationModel.fromJson(e)).toList();
  }

  Future<List<LocationModel>> getAllLocations() async {
    final response = await _dio.get('/locations/all');
    final list = response.data as List;
    return list.map((e) => LocationModel.fromJson(e)).toList();
  }
}

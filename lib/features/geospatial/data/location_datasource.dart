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


class IncineratorStatusModel {
  final String deviceId;
  final double? temperatureCelsius;
  final bool isBurning;
  final double? fillPercentage;
  final int usageCount;
  final double? batteryLevel;
  final bool isOnline;

  const IncineratorStatusModel({
    required this.deviceId,
    this.temperatureCelsius,
    required this.isBurning,
    this.fillPercentage,
    required this.usageCount,
    this.batteryLevel,
    required this.isOnline,
  });

  factory IncineratorStatusModel.fromJson(Map<String, dynamic> json) {
    return IncineratorStatusModel(
      deviceId: json['device_id'] as String,
      temperatureCelsius: json['temperature_celsius'] != null
          ? (json['temperature_celsius'] as num).toDouble()
          : null,
      isBurning: json['is_burning'] as bool? ?? false,
      fillPercentage: json['fill_percentage'] != null
          ? (json['fill_percentage'] as num).toDouble()
          : null,
      usageCount: json['usage_count'] as int? ?? 0,
      batteryLevel: json['battery_level'] != null
          ? (json['battery_level'] as num).toDouble()
          : null,
      isOnline: json['is_online'] as bool? ?? false,
    );
  }
}

extension IncineratorDataSource on LocationDataSource {
  Future<IncineratorStatusModel?> getIncineratorStatus(
      String deviceId) async {
    try {
      final response =
          await _dio.get('/incinerators/$deviceId/status');
      return IncineratorStatusModel.fromJson(
          response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

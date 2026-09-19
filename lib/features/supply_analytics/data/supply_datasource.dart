import 'package:dio/dio.dart';

class SupplyAnalytics {
  final int totalPadsDistributed;
  final int totalBeneficiaries;
  final int distributedLast30Days;
  final List<LocationSupply> byLocation;
  final List<LowStockAlert> lowStockAlerts;

  const SupplyAnalytics({
    required this.totalPadsDistributed,
    required this.totalBeneficiaries,
    required this.distributedLast30Days,
    required this.byLocation,
    required this.lowStockAlerts,
  });

  factory SupplyAnalytics.fromJson(Map<String, dynamic> json) {
    return SupplyAnalytics(
      totalPadsDistributed: json['total_pads_distributed'] as int? ?? 0,
      totalBeneficiaries: json['total_beneficiaries'] as int? ?? 0,
      distributedLast30Days: json['distributed_last_30_days'] as int? ?? 0,
      byLocation: (json['by_location'] as List? ?? [])
          .map((e) => LocationSupply.fromJson(e))
          .toList(),
      lowStockAlerts: (json['low_stock_alerts'] as List? ?? [])
          .map((e) => LowStockAlert.fromJson(e))
          .toList(),
    );
  }
}

class LocationSupply {
  final String location;
  final int totalPads;
  final int totalBeneficiaries;
  final int distributionCount;

  const LocationSupply({
    required this.location,
    required this.totalPads,
    required this.totalBeneficiaries,
    required this.distributionCount,
  });

  factory LocationSupply.fromJson(Map<String, dynamic> json) {
    return LocationSupply(
      location: json['location'] as String,
      totalPads: json['total_pads'] as int? ?? 0,
      totalBeneficiaries: json['total_beneficiaries'] as int? ?? 0,
      distributionCount: json['distribution_count'] as int? ?? 0,
    );
  }
}

class LowStockAlert {
  final String locationId;
  final String locationName;
  final int currentStock;
  final int minimumThreshold;

  const LowStockAlert({
    required this.locationId,
    required this.locationName,
    required this.currentStock,
    required this.minimumThreshold,
  });

  factory LowStockAlert.fromJson(Map<String, dynamic> json) {
    return LowStockAlert(
      locationId: json['location_id'] as String,
      locationName: json['location_name'] as String,
      currentStock: json['current_stock'] as int? ?? 0,
      minimumThreshold: json['minimum_threshold'] as int? ?? 50,
    );
  }
}

class SupplyDataSource {
  final _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  Future<SupplyAnalytics> getAnalytics() async {
    final response = await _dio.get('/supply/analytics');
    return SupplyAnalytics.fromJson(response.data as Map<String, dynamic>);
  }
}

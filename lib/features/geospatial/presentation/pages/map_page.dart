import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../../data/location_datasource.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  LocationModel? _selectedLocation;

  static const LatLng _keralaCenter = LatLng(9.5916, 76.5222);

  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const MapLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disposal & Supply Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              context.read<MapBloc>().add(const MapLoadRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoading || state is MapInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MapError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  const Text('Could not load map data'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context
                        .read<MapBloc>()
                        .add(const MapLoadRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final loaded = state as MapLoaded;
          final userLocation = loaded.userLat != null
              ? LatLng(loaded.userLat!, loaded.userLng!)
              : null;

          final incinerators = loaded.locations
              .where((l) => l.locationType == 'incinerator')
              .toList();
          final supplyPoints = loaded.locations
              .where((l) => l.locationType == 'supply_point')
              .toList();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: userLocation ?? _keralaCenter,
                  initialZoom: 10,
                  onTap: (_, __) => setState(() => _selectedLocation = null),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.cycleai.app',
                  ),
                  MarkerLayer(
                    markers: [
                      if (userLocation != null)
                        Marker(
                          point: userLocation,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ...incinerators.map((loc) => Marker(
                            point: LatLng(loc.latitude, loc.longitude),
                            width: 44,
                            height: 44,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedLocation = loc),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.local_fire_department,
                                    color: Colors.white, size: 22),
                              ),
                            ),
                          )),
                      ...supplyPoints.map((loc) => Marker(
                            point: LatLng(loc.latitude, loc.longitude),
                            width: 44,
                            height: 44,
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedLocation = loc),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.shopping_bag_outlined,
                                    color: Colors.white, size: 22),
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 12,
                left: 12,
                child: _Legend(),
              ),
              if (_selectedLocation != null)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _LocationCard(
                    location: _selectedLocation!,
                    onClose: () =>
                        setState(() => _selectedLocation = null),
                  ),
                ),
              if (loaded.locations.isEmpty)
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No locations found in this area'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegendItem(color: Colors.red.shade600, icon: Icons.local_fire_department, label: 'Incinerator'),
          const SizedBox(height: 6),
          _LegendItem(color: Colors.green.shade600, icon: Icons.shopping_bag_outlined, label: 'Supply Point'),
          const SizedBox(height: 6),
          _LegendItem(color: Colors.blue, icon: Icons.person, label: 'You'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _LegendItem({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 12),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  final LocationModel location;
  final VoidCallback onClose;

  const _LocationCard({required this.location, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final isIncinerator = location.locationType == 'incinerator';
    final color = isIncinerator ? Colors.red.shade600 : Colors.green.shade600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncinerator
                  ? Icons.local_fire_department
                  : Icons.shopping_bag_outlined,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                if (location.address != null)
                  Text(
                    location.address!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.grey600),
                  ),
                if (location.distanceKm != null)
                  Text(
                    '${location.distanceKm!.toStringAsFixed(1)} km away',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

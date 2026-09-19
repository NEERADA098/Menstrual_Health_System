import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/supply_bloc.dart';
import '../bloc/supply_event.dart';
import '../bloc/supply_state.dart';

class SupplyAnalyticsPage extends StatefulWidget {
  const SupplyAnalyticsPage({super.key});

  @override
  State<SupplyAnalyticsPage> createState() => _SupplyAnalyticsPageState();
}

class _SupplyAnalyticsPageState extends State<SupplyAnalyticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SupplyBloc>().add(const SupplyLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pad Supply Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<SupplyBloc>().add(const SupplyLoadRequested()),
          ),
        ],
      ),
      body: BlocBuilder<SupplyBloc, SupplyState>(
        builder: (context, state) {
          if (state is SupplyLoading || state is SupplyInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SupplyError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off,
                      size: 48, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  const Text('Could not load supply data'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => context
                        .read<SupplyBloc>()
                        .add(const SupplyLoadRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final analytics = (state as SupplyLoaded).analytics;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (analytics.lowStockAlerts.isNotEmpty) ...[
                  _LowStockBanner(alerts: analytics.lowStockAlerts),
                  const SizedBox(height: 20),
                ],
                Text('Overview',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _StatCard(
                      label: 'Total Pads Distributed',
                      value: '${analytics.totalPadsDistributed}',
                      icon: Icons.shopping_bag_outlined,
                      color: AppColors.primary,
                    ),
                    _StatCard(
                      label: 'Women Reached',
                      value: '${analytics.totalBeneficiaries}',
                      icon: Icons.people_outline,
                      color: Colors.green,
                    ),
                    _StatCard(
                      label: 'Last 30 Days',
                      value: '${analytics.distributedLast30Days}',
                      icon: Icons.calendar_month,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      label: 'Low Stock Alerts',
                      value: '${analytics.lowStockAlerts.length}',
                      icon: Icons.warning_amber_outlined,
                      color: analytics.lowStockAlerts.isNotEmpty
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('Distribution by Location',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (analytics.byLocation.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No distribution data yet'),
                    ),
                  )
                else
                  ...analytics.byLocation.map(
                    (loc) => _LocationDistributionCard(location: loc),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LowStockBanner extends StatelessWidget {
  final List<dynamic> alerts;
  const _LowStockBanner({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Low Stock Alert',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...alerts.map((alert) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '• ${alert.locationName}: ${alert.currentStock} pads remaining '
                  '(minimum: ${alert.minimumThreshold})',
                  style: const TextStyle(fontSize: 13),
                ),
              )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.grey600)),
        ],
      ),
    );
  }
}

class _LocationDistributionCard extends StatelessWidget {
  final dynamic location;
  const _LocationDistributionCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            location.location,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MiniStat(
                  label: 'Pads', value: '${location.totalPads}'),
              const SizedBox(width: 16),
              _MiniStat(
                  label: 'Women', value: '${location.totalBeneficiaries}'),
              const SizedBox(width: 16),
              _MiniStat(
                  label: 'Events', value: '${location.distributionCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.primary)),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.grey600)),
      ],
    );
  }
}

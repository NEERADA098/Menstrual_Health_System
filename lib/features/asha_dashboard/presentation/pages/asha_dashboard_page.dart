import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/asha_bloc.dart';
import '../bloc/asha_event.dart';
import '../bloc/asha_state.dart';

class AshaDashboardPage extends StatefulWidget {
  const AshaDashboardPage({super.key});

  @override
  State<AshaDashboardPage> createState() => _AshaDashboardPageState();
}

class _AshaDashboardPageState extends State<AshaDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<AshaBloc>().add(const AshaDashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('ASHA Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<AshaBloc>()
                .add(const AshaDashboardLoadRequested()),
          ),
        ],
      ),
      body: BlocBuilder<AshaBloc, AshaState>(
        builder: (context, state) {
          if (state is AshaLoading || state is AshaInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AshaError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  Text(
                    'Could not connect to server',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.grey600, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final loaded = state as AshaLoaded;
          final summary = loaded.summary;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _StatCard(
                      label: 'Total Users',
                      value: '${summary['total_users'] ?? 0}',
                      icon: Icons.people_outline,
                      color: AppColors.primary,
                    ),
                    _StatCard(
                      label: 'Active This Week',
                      value: '${summary['active_this_week'] ?? 0}',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    _StatCard(
                      label: 'Cycles Logged',
                      value: '${summary['total_cycles_logged'] ?? 0}',
                      icon: Icons.calendar_today,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      label: 'Flagged Users',
                      value: '${summary['users_with_severe_symptoms'] ?? 0}',
                      icon: Icons.warning_amber_outlined,
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Users Requiring Follow-up',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '3 or more severe symptom entries',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.grey600),
                ),
                const SizedBox(height: 12),
                if (loaded.flaggedUsers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green),
                        SizedBox(width: 12),
                        Text('No users flagged for follow-up'),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: loaded.flaggedUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = loaded.flaggedUsers[index];
                      return _FlaggedUserCard(user: user);
                    },
                  ),
              ],
            ),
          );
        },
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
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}

class _FlaggedUserCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const _FlaggedUserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ${(user['user_id'] as String).substring(0, 8)}...',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${user['severe_symptom_count']} severe entries · ${user['flag_reason']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey400),
        ],
      ),
    );
  }
}

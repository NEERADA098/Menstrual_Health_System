import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/cycle_bloc.dart';
import '../bloc/cycle_event.dart';
import '../bloc/cycle_state.dart';
import '../widgets/cycle_progress_ring.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load cycle data as soon as this screen appears
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CycleBloc>().add(CycleLoadRequested(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: const Text('CycleAI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => context.go('/calendar'),
          ),
        ],
      ),
      body: BlocBuilder<CycleBloc, CycleState>(
        builder: (context, state) {
          if (state is CycleLoading || state is CycleInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CycleError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          }

          final loaded = state as CycleLoaded;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                CycleProgressRing(
                  currentDay: loaded.currentCycleDay,
                  averageCycleLength: loaded.averageCycleLength,
                  daysUntilNextPeriod: loaded.predictedDaysUntilNextPeriod,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.push('/log-period'),
                  icon: const Icon(Icons.add),
                  label: const Text('Log Period'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.push('/log-symptom'),
                  icon: const Icon(Icons.mood),
                  label: const Text('Log Symptoms'),
                ),
                const SizedBox(height: 24),
                _QuickStatsRow(
                  averageCycleLength: loaded.averageCycleLength,
                  totalLogged: loaded.history.length,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final int averageCycleLength;
  final int totalLogged;

  const _QuickStatsRow({
    required this.averageCycleLength,
    required this.totalLogged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Avg. Cycle Length',
            value: '$averageCycleLength days',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Cycles Logged',
            value: '$totalLogged',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

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
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}

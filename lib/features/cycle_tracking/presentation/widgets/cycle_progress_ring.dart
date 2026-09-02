import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// CycleProgressRing - Visual circular indicator showing where the
/// user is in their cycle. The centerpiece of the home dashboard.
class CycleProgressRing extends StatelessWidget {
  final int? currentDay;
  final int averageCycleLength;
  final int? daysUntilNextPeriod;

  const CycleProgressRing({
    super.key,
    required this.currentDay,
    required this.averageCycleLength,
    required this.daysUntilNextPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentDay != null
        ? (currentDay! / averageCycleLength).clamp(0.0, 1.0)
        : 0.0;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 14,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (currentDay != null) ...[
                Text(
                  'Day $currentDay',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  daysUntilNextPeriod != null && daysUntilNextPeriod! > 0
                      ? 'Next period in $daysUntilNextPeriod days'
                      : 'Period may be due',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                const Icon(
                  Icons.favorite_border,
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                const Text(
                  'No cycle logged yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
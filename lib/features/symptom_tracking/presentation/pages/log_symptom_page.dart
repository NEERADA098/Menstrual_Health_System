import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/symptom_entity.dart';
import '../bloc/symptom_bloc.dart';
import '../bloc/symptom_event.dart';
import '../bloc/symptom_state.dart';

class LogSymptomPage extends StatefulWidget {
  const LogSymptomPage({super.key});

  @override
  State<LogSymptomPage> createState() => _LogSymptomPageState();
}

class _LogSymptomPageState extends State<LogSymptomPage> {
  final Set<SymptomType> _selectedSymptoms = {};
  SymptomSeverity _severity = SymptomSeverity.mild;
  final DateTime _logDate = DateTime.now();

  // Clinically validated display names
  String _symptomDisplayName(SymptomType type) {
    switch (type) {
      case SymptomType.cramps:
        return 'Cramps';
      case SymptomType.backPain:
        return 'Back Pain';
      case SymptomType.headache:
        return 'Headache';
      case SymptomType.bloating:
        return 'Bloating';
      case SymptomType.breastTenderness:
        return 'Breast Tenderness';
      case SymptomType.nausea:
        return 'Nausea';
      case SymptomType.fatigue:
        return 'Fatigue';
      case SymptomType.dizziness:
        return 'Dizziness';
      case SymptomType.acne:
        return 'Acne';
      case SymptomType.facialHair:
        return 'Facial Hair';
      case SymptomType.moodSwings:
        return 'Mood Swings';
      case SymptomType.anxiety:
        return 'Anxiety';
      case SymptomType.irritability:
        return 'Irritability';
    }
  }

  IconData _symptomIcon(SymptomType type) {
    switch (type) {
      case SymptomType.cramps:
        return Icons.sick_outlined;
      case SymptomType.backPain:
        return Icons.accessibility_new;
      case SymptomType.headache:
        return Icons.psychology_outlined;
      case SymptomType.bloating:
        return Icons.water_drop_outlined;
      case SymptomType.breastTenderness:
        return Icons.favorite_border;
      case SymptomType.nausea:
        return Icons.sentiment_dissatisfied_outlined;
      case SymptomType.fatigue:
        return Icons.battery_1_bar;
      case SymptomType.dizziness:
        return Icons.rotate_right;
      case SymptomType.acne:
        return Icons.face_outlined;
      case SymptomType.facialHair:
        return Icons.face_3_outlined;
      case SymptomType.moodSwings:
        return Icons.swap_horiz;
      case SymptomType.anxiety:
        return Icons.warning_amber_outlined;
      case SymptomType.irritability:
        return Icons.mood_bad_outlined;
    }
  }

  void _submit() {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    for (final symptom in _selectedSymptoms) {
      context.read<SymptomBloc>().add(SymptomLogRequested(
            userId: authState.user.uid,
            logDate: _logDate,
            symptomType: symptom,
            severity: _severity,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SymptomBloc, SymptomState>(
      listener: (context, state) {
        if (state is SymptomLoaded) context.pop();
        if (state is SymptomError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Log Symptoms')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How are you feeling today?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Select all that apply',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: 20),

              // Symptom grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SymptomType.values.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return FilterChip(
                    avatar: Icon(
                      _symptomIcon(symptom),
                      size: 18,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.grey600,
                    ),
                    label: Text(_symptomDisplayName(symptom)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSymptoms.add(symptom);
                        } else {
                          _selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryLight,
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),
              Text(
                'How severe?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Based on how much it affects your daily activities',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: 12),

              // Severity selector
              Row(
                children: SymptomSeverity.values.map((s) {
                  final isSelected = _severity == s;
                  final label = s == SymptomSeverity.mild
                      ? 'Mild'
                      : s == SymptomSeverity.moderate
                          ? 'Moderate'
                          : 'Severe';
                  final color = s == SymptomSeverity.mild
                      ? Colors.green
                      : s == SymptomSeverity.moderate
                          ? Colors.orange
                          : Colors.red;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => setState(() => _severity = s),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.15)
                                : AppColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : AppColors.grey300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                s == SymptomSeverity.mild
                                    ? Icons.sentiment_satisfied_outlined
                                    : s == SymptomSeverity.moderate
                                        ? Icons.sentiment_neutral_outlined
                                        : Icons.sentiment_very_dissatisfied_outlined,
                                color: isSelected ? color : AppColors.grey600,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected ? color : AppColors.grey700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),

              // CLINICAL NOTE: Congestive dysmenorrhea warning
              // Per gynecologist: pain starting before period and lasting
              // 4-6 days is clinically significant (not normal).
              if (_selectedSymptoms.contains(SymptomType.cramps) &&
                  _severity == SymptomSeverity.severe)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Severe cramps that affect daily activities or start before your period may be worth discussing with a doctor.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              BlocBuilder<SymptomBloc, SymptomState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed:
                        state is SymptomLoading ? null : _submit,
                    child: state is SymptomLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text('Save Symptoms'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

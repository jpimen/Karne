import 'package:flutter/material.dart';
import '../models/api_models.dart';

class ProgramDetailScreen extends StatelessWidget {
  final TrainingProgram program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          program.name.toUpperCase(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFF111111),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Program info card
              Card(
                color: const Color(0xFF1a1a1a),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              program.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getProgramTypeColor(program.programType),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              program.programType.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFD4A017),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Week ${program.weekCurrent} of ${program.weekTotal}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Color(0xFFD4A017),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Created ${_formatDate(program.createdAt)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Training days
              Text(
                'TRAINING DAYS',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              if (program.days.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No training days configured',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              else
                ...program.days.map((day) => _TrainingDayCard(day: day)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgramTypeColor(String programType) {
    switch (programType.toLowerCase()) {
      case 'hypertrophy':
        return const Color(0xFFD4A017); // Gold
      case 'strength':
        return Colors.red;
      case 'power':
        return Colors.blue;
      case 'deload':
        return Colors.green;
      default:
        return const Color(0xFFD4A017);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _TrainingDayCard extends StatelessWidget {
  final TrainingDay day;

  const _TrainingDayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1a1a1a),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4A017),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.dayOfWeek}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    day.dayLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (day.exercises.isEmpty)
              const Text(
                'No exercises configured',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              )
            else
              ...day.exercises.map(
                (exercise) => _ExerciseItem(exercise: exercise),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  final ProgramExercise exercise;

  const _ExerciseItem({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.exercise.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (exercise.exercise.category != null ||
              exercise.exercise.muscleGroup != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                [
                  exercise.exercise.category,
                  exercise.exercise.muscleGroup,
                ].where((item) => item != null && item.isNotEmpty).join(' • '),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ExerciseDetail(label: 'SETS', value: '${exercise.sets}'),
              const SizedBox(width: 16),
              _ExerciseDetail(label: 'REPS', value: exercise.reps),
              if (exercise.targetWeight > 0) ...[
                const SizedBox(width: 16),
                _ExerciseDetail(
                  label: 'WEIGHT',
                  value: '${exercise.targetWeight}kg',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseDetail extends StatelessWidget {
  final String label;
  final String value;

  const _ExerciseDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/index.dart';
import '../index.dart';

class ProgramDetailScreen extends StatelessWidget {
  final TrainingProgram program;
  final int selectedWeek;
  final TrainingDay selectedDay;

  const ProgramDetailScreen({
    super.key,
    required this.program,
    required this.selectedWeek,
    required this.selectedDay,
  });

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
                            'Week $selectedWeek Overview',
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

              const SizedBox(height: 24),

              // Embedded Workout Log Spreadsheet View
              WorkoutLogView(trainingDay: selectedDay),
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




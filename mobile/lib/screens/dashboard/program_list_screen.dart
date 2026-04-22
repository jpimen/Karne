import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/index.dart';
import '../../providers/index.dart';
import '../index.dart';

class ProgramListScreen extends StatefulWidget {
  const ProgramListScreen({super.key});

  @override
  State<ProgramListScreen> createState() => _ProgramListScreenState();
}

class _ProgramListScreenState extends State<ProgramListScreen> {
  List<TrainingProgram> _programs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final programs = await appProvider.apiService.getPrograms();

      setState(() {
        if (programs.isEmpty) {
          // Temporarily inject a mock program for UI testing since the DB is empty
          _programs = [
            TrainingProgram(
              id: 999,
              name: 'POWER HYPERTROPHY',
              weekCurrent: 1,
              weekTotal: 8,
              programType: 'hypertrophy',
              createdAt: DateTime.now(),
              days: [
                TrainingDay(id: 1, dayOfWeek: 1, dayLabel: 'Lower Body', exercises: []),
                TrainingDay(id: 2, dayOfWeek: 2, dayLabel: 'Upper Body', exercises: []),
              ],
            )
          ];
        } else {
          _programs = programs;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PROGRAMS',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadPrograms),
        ],
      ),
      body: Container(
        color: const Color(0xFF111111),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4A017)),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading programs',
                          style: TextStyle(color: Colors.red[300]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPrograms,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4A017),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('RETRY'),
                        ),
                      ],
                    ),
                  )
                : _programs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fitness_center,
                                color: Colors.grey, size: 64),
                            SizedBox(height: 16),
                            Text(
                              'No programs found',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create a program in the web app first',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPrograms,
                        color: const Color(0xFFD4A017),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _programs.length,
                          itemBuilder: (context, index) {
                            final program = _programs[index];
                            return _ProgramCard(
                              program: program,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProgramOverviewScreen(program: program),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final TrainingProgram program;
  final VoidCallback onTap;

  const _ProgramCard({required this.program, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1a1a1a),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      program.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgramTypeColor(program.programType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      program.programType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFFD4A017),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Week ${program.weekCurrent} of ${program.weekTotal}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFFD4A017),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Created ${_formatDate(program.createdAt)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${program.days.length} training days',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFFD4A017),
                    size: 16,
                  ),
                ],
              ),
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
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}



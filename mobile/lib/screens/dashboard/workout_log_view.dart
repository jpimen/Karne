import 'package:flutter/material.dart';

import '../../models/index.dart';
class WorkoutLogView extends StatefulWidget {
  final TrainingDay trainingDay;
  const WorkoutLogView({super.key, required this.trainingDay});

  @override
  State<WorkoutLogView> createState() => _WorkoutLogViewState();
}

class _WorkoutLogViewState extends State<WorkoutLogView> {
  // Track session volume dynamically
  double _squatTotal = 700;
  double _benchTotal = 500;
  double _deadliftTotal = 540;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        // Title
        Text(
          widget.trainingDay.dayLabel.toUpperCase(),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),

        // Exercises Card
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F1F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: const [
                    Expanded(flex: 3, child: Text('EXERCISE', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                    Expanded(flex: 1, child: Text('RPE', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                    Expanded(flex: 1, child: Text('REPS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                    Expanded(flex: 2, child: Text('LOAD', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                    Expanded(flex: 2, child: Text('LIFTED', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                    Expanded(flex: 2, child: Text('TOTAL', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                    Expanded(flex: 1, child: Text('NOTES', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0))),
                  ],
                ),
              ),
              // Table Body Rows
              ...widget.trainingDay.exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                final isLast = index == widget.trainingDay.exercises.length - 1;

                return ExerciseRow(
                  name: exercise.exercise.name.toUpperCase(),
                  detail: exercise.exercise.category ?? '',
                  rpe: '8.0', // Target RPE could be added to model
                  reps: exercise.reps,
                  load: '${exercise.targetWeight}kg',
                  initialTotal: (exercise.sets * exercise.targetWeight).toStringAsFixed(0),
                  isLast: isLast,
                  onTotalChanged: (val) {
                    // Update volume totals based on muscle group or exercise name
                  },
                );
              }),
              
              // Add Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Color(0xFFD4A017), size: 16),
                  label: const Text(
                    'ADD EXERCISE',
                    style: TextStyle(
                      color: Color(0xFFD4A017),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
        // Session Volume Totals
        const Text(
          'SESSION VOLUME TOTALS',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildVolumeCard('SQUAT', _squatTotal, 'KG'),
              const SizedBox(width: 12),
              _buildVolumeCard('BENCH', _benchTotal, 'KG'),
              const SizedBox(width: 12),
              _buildVolumeCard('DEADLIFT', _deadliftTotal, 'KG'),
            ],
          ),
        ),

        const SizedBox(height: 30),
        // Intensity Trend Card
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F1F),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'INTENSITY TREND',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '+4.2% from last week',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.trending_up, color: Color(0xFFD4A017)),
                  ],
                ),
              ),
              SizedBox(
                height: 100,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  child: CustomPaint(
                    painter: ChartPainter(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildVolumeCard(String title, double value, String unit) {
    // Fixed typo converting safely avoiding Javascript issue
    final isInt = value % 1 == 0;
    final valueStr = isInt ? value.toInt().toString() : value.toStringAsFixed(1);
    final formattedValue = valueStr.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return Container(
      width: 140, 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: formattedValue,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'Roboto'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: const TextStyle(color: Color(0xFFD4A017), fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final path = Path();
    path.moveTo(0, height * 0.95);
    
    path.cubicTo(
      width * 0.3, height * 0.95,
      width * 0.6, height * 1.05,
      width * 0.7, height * 0.5,
    );
    path.quadraticBezierTo(
      width * 0.85, height * 0.15,
      width, height * 0.25,
    );

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = const Color(0xFFD4A017);

    final fillPath = Path.from(path);
    fillPath.lineTo(width, height);
    fillPath.lineTo(0, height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD4A017).withOpacity(0.15),
          const Color(0xFFD4A017).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(0, 0, width, height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ExerciseRow extends StatefulWidget {
  final String name;
  final String detail;
  final String rpe;
  final String reps;
  final String load;
  final String initialTotal;
  final bool isLast;
  final Function(double) onTotalChanged;

  const ExerciseRow({
    super.key,
    required this.name,
    required this.detail,
    required this.rpe,
    required this.reps,
    required this.load,
    required this.initialTotal,
    required this.onTotalChanged,
    this.isLast = false,
  });

  @override
  State<ExerciseRow> createState() => _ExerciseRowState();
}

class _ExerciseRowState extends State<ExerciseRow> {
  final TextEditingController _controller = TextEditingController();
  String _calculatedTotal = '';

  @override
  void initState() {
    super.initState();
    _calculatedTotal = widget.initialTotal;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculateTotal(String input) {
    if (input.trim().isEmpty) {
      setState(() {
        _calculatedTotal = widget.initialTotal;
      });
      widget.onTotalChanged(double.tryParse(widget.initialTotal) ?? 0);
      return;
    }

    final normalized = input.replaceAll(RegExp(r'[,|;\s/]+'), '-');
    final parts = normalized.split('-');

    double sum = 0;
    bool hasValidNumber = false;
    for (var part in parts) {
      final val = double.tryParse(part.trim());
      if (val != null) {
        sum += val;
        hasValidNumber = true;
      }
    }

    setState(() {
      if (hasValidNumber) {
        if (sum == sum.toInt()) {
          _calculatedTotal = sum.toInt().toString();
        } else {
          _calculatedTotal = sum.toString();
        }
        widget.onTotalChanged(sum);
      } else {
        _calculatedTotal = widget.initialTotal;
        widget.onTotalChanged(double.tryParse(widget.initialTotal) ?? 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24, left: 16, right: 16, bottom: widget.isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, height: 1.2, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.detail,
                  style: const TextStyle(color: Color(0xFF666666), fontSize: 10),
                ),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(widget.rpe, style: const TextStyle(color: Color(0xFFD4A017), fontWeight: FontWeight.w900, fontSize: 12))),
          Expanded(flex: 1, child: Text(widget.reps, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12))),
          Expanded(flex: 2, child: Text(widget.load, style: const TextStyle(color: Color(0xFFD4A017), fontWeight: FontWeight.w900, fontSize: 12))),
          Expanded(
            flex: 2,
            child: Container(
              height: 24,
              margin: const EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controller,
                onChanged: _calculateTotal,
                keyboardType: TextInputType.text,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: const Color(0xFF111111),
                  hintText: 'kg',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
            ),
          ),
          Expanded(flex: 2, child: Text(_calculatedTotal, style: const TextStyle(color: Colors.grey, fontSize: 12))),
          Expanded(flex: 1, child: Icon(Icons.notes, color: Colors.grey[700], size: 16)),
        ],
      ),
    );
  }
}



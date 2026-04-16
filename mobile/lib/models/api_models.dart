class User {
  final int id;
  final String username;
  final String? avatar;
  final String status;
  final String subscriptionTier;

  User({
    required this.id,
    required this.username,
    this.avatar,
    required this.status,
    required this.subscriptionTier,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      avatar: json['avatar'],
      status: json['status'] ?? 'novice',
      subscriptionTier: json['subscription_tier'] ?? 'free',
    );
  }
}

class TrainingProgram {
  final int id;
  final String name;
  final int weekCurrent;
  final int weekTotal;
  final String programType;
  final DateTime createdAt;
  final List<TrainingDay> days;

  TrainingProgram({
    required this.id,
    required this.name,
    required this.weekCurrent,
    required this.weekTotal,
    required this.programType,
    required this.createdAt,
    required this.days,
  });

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    final createdAtString = json['created_at']?.toString();
    return TrainingProgram(
      id: json['id'],
      name: json['name'],
      weekCurrent: json['week_current'] ?? 1,
      weekTotal: json['week_total'] ?? 8,
      programType: json['program_type'] ?? 'hypertrophy',
      createdAt: DateTime.tryParse(createdAtString ?? '') ?? DateTime.now(),
      days:
          (json['days'] as List<dynamic>?)
              ?.map((day) => TrainingDay.fromJson(day))
              .toList() ??
          [],
    );
  }
}

class TrainingDay {
  final int id;
  final int dayOfWeek;
  final String dayLabel;
  final List<ProgramExercise> exercises;

  TrainingDay({
    required this.id,
    required this.dayOfWeek,
    required this.dayLabel,
    required this.exercises,
  });

  factory TrainingDay.fromJson(Map<String, dynamic> json) {
    return TrainingDay(
      id: json['id'],
      dayOfWeek: json['day_of_week'],
      dayLabel: json['day_label'],
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((exercise) => ProgramExercise.fromJson(exercise))
              .toList() ??
          [],
    );
  }
}

class ProgramExercise {
  final int id;
  final Exercise exercise;
  final int sets;
  final String reps;
  final double targetWeight;

  ProgramExercise({
    required this.id,
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.targetWeight,
  });

  factory ProgramExercise.fromJson(Map<String, dynamic> json) {
    return ProgramExercise(
      id: json['id'],
      exercise: Exercise.fromJson(json['exercise']),
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? '8',
      targetWeight: (json['target_weight'] ?? 0.0).toDouble(),
    );
  }
}

class Exercise {
  final int id;
  final String name;
  final String? category;
  final String? muscleGroup;

  Exercise({
    required this.id,
    required this.name,
    this.category,
    this.muscleGroup,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      muscleGroup: json['muscle_group'],
    );
  }
}

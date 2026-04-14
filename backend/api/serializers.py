from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import (
    TrainingProgram,
    TrainingDay,
    Exercise,
    ProgramExercise,
    WorkoutSession,
    SessionSet,
    PersonalRecord,
)

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'avatar', 'status', 'subscription_tier']

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['username', 'email', 'password']

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email'),
            password=validated_data['password'],
        )
        return user

class ExerciseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Exercise
        fields = ['id', 'name', 'category', 'muscle_group']

class ProgramExerciseSerializer(serializers.ModelSerializer):
    exercise = ExerciseSerializer(read_only=True)
    exercise_id = serializers.PrimaryKeyRelatedField(queryset=Exercise.objects.all(), source='exercise', write_only=True)

    class Meta:
        model = ProgramExercise
        fields = ['id', 'exercise', 'exercise_id', 'sets', 'reps', 'target_weight']

class TrainingDaySerializer(serializers.ModelSerializer):
    exercises = ProgramExerciseSerializer(many=True)

    class Meta:
        model = TrainingDay
        fields = ['id', 'day_of_week', 'day_label', 'exercises']

    def create(self, validated_data):
        exercises_data = validated_data.pop('exercises', [])
        day = TrainingDay.objects.create(**validated_data)
        for exercise_data in exercises_data:
            ProgramExercise.objects.create(day=day, **exercise_data)
        return day

    def update(self, instance, validated_data):
        exercises_data = validated_data.pop('exercises', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if exercises_data is not None:
            instance.exercises.all().delete()
            for exercise_data in exercises_data:
                ProgramExercise.objects.create(day=instance, **exercise_data)
        return instance

class TrainingProgramSerializer(serializers.ModelSerializer):
    days = TrainingDaySerializer(many=True)

    class Meta:
        model = TrainingProgram
        fields = ['id', 'name', 'week_current', 'week_total', 'program_type', 'days']

    def create(self, validated_data):
        days_data = validated_data.pop('days', [])
        program = TrainingProgram.objects.create(**validated_data)
        for day_data in days_data:
            exercises_data = day_data.pop('exercises', [])
            day = TrainingDay.objects.create(program=program, **day_data)
            for exercise_data in exercises_data:
                ProgramExercise.objects.create(day=day, **exercise_data)
        return program

    def update(self, instance, validated_data):
        days_data = validated_data.pop('days', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if days_data is not None:
            instance.days.all().delete()
            for day_data in days_data:
                exercises_data = day_data.pop('exercises', [])
                day = TrainingDay.objects.create(program=instance, **day_data)
                for exercise_data in exercises_data:
                    ProgramExercise.objects.create(day=day, **exercise_data)
        return instance

class SessionSetSerializer(serializers.ModelSerializer):
    exercise = ExerciseSerializer()

    class Meta:
        model = SessionSet
        fields = ['id', 'exercise', 'set_number', 'reps', 'weight_kg', 'rpe']

class WorkoutSessionSerializer(serializers.ModelSerializer):
    sets = SessionSetSerializer(many=True, read_only=True)

    class Meta:
        model = WorkoutSession
        fields = ['id', 'date', 'duration_minutes', 'total_volume_kg', 'effort_tag', 'notes', 'sets']

class PersonalRecordSerializer(serializers.ModelSerializer):
    exercise = ExerciseSerializer()

    class Meta:
        model = PersonalRecord
        fields = ['id', 'exercise', 'weight_kg', 'date_achieved']

from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import (
    Assignment,
    Day,
    LoggedSet,
    Program,
    ProgramExercise,
    Session,
    User,
    Week,
)

User = get_user_model()


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


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'avatar', 'status', 'subscription_tier']


class ProgramExerciseSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProgramExercise
        fields = [
            'id',
            'order',
            'name',
            'sets',
            'reps',
            'load',
            'rpe',
            'intensity',
            'rest',
            'notes',
        ]


class DaySerializer(serializers.ModelSerializer):
    exercises = ProgramExerciseSerializer(many=True)

    class Meta:
        model = Day
        fields = ['id', 'day_number', 'label', 'exercises']

    def create(self, validated_data):
        exercises_data = validated_data.pop('exercises', [])
        day = Day.objects.create(**validated_data)
        for index, exercise_data in enumerate(exercises_data):
            ProgramExercise.objects.create(day=day, order=index, **exercise_data)
        return day

    def update(self, instance, validated_data):
        exercises_data = validated_data.pop('exercises', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if exercises_data is not None:
            instance.exercises.all().delete()
            for index, exercise_data in enumerate(exercises_data):
                ProgramExercise.objects.create(day=instance, order=index, **exercise_data)
        return instance


class WeekSerializer(serializers.ModelSerializer):
    days = DaySerializer(many=True)

    class Meta:
        model = Week
        fields = ['id', 'week_number', 'days']

    def create(self, validated_data):
        days_data = validated_data.pop('days', [])
        week = Week.objects.create(**validated_data)
        for day_data in days_data:
            exercises_data = day_data.pop('exercises', [])
            day = Day.objects.create(week=week, **day_data)
            for index, exercise_data in enumerate(exercises_data):
                ProgramExercise.objects.create(day=day, order=index, **exercise_data)
        return week

    def update(self, instance, validated_data):
        days_data = validated_data.pop('days', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if days_data is not None:
            instance.days.all().delete()
            for day_data in days_data:
                exercises_data = day_data.pop('exercises', [])
                day = Day.objects.create(week=instance, **day_data)
                for index, exercise_data in enumerate(exercises_data):
                    ProgramExercise.objects.create(day=day, order=index, **exercise_data)
        return instance


class ProgramSerializer(serializers.ModelSerializer):
    weeks = WeekSerializer(many=True)
    coach_id = serializers.PrimaryKeyRelatedField(source='coach', read_only=True)

    class Meta:
        model = Program
        fields = [
            'id',
            'coach_id',
            'name',
            'duration_weeks',
            'frequency_per_week',
            'goal',
            'description',
            'status',
            'created_at',
            'published_at',
            'weeks',
        ]
        read_only_fields = ['coach_id', 'created_at', 'published_at']

    def create(self, validated_data):
        weeks_data = validated_data.pop('weeks', [])
        program = Program.objects.create(**validated_data)
        for week_data in weeks_data:
            days_data = week_data.pop('days', [])
            week = Week.objects.create(program=program, **week_data)
            for day_data in days_data:
                exercises_data = day_data.pop('exercises', [])
                day = Day.objects.create(week=week, **day_data)
                for index, exercise_data in enumerate(exercises_data):
                    ProgramExercise.objects.create(day=day, order=index, **exercise_data)
        return program

    def update(self, instance, validated_data):
        weeks_data = validated_data.pop('weeks', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if weeks_data is not None:
            instance.weeks.all().delete()
            for week_data in weeks_data:
                days_data = week_data.pop('days', [])
                week = Week.objects.create(program=instance, **week_data)
                for day_data in days_data:
                    exercises_data = day_data.pop('exercises', [])
                    day = Day.objects.create(week=week, **day_data)
                    for index, exercise_data in enumerate(exercises_data):
                        ProgramExercise.objects.create(day=day, order=index, **exercise_data)
        return instance


class AssignmentSerializer(serializers.ModelSerializer):
    program_id = serializers.PrimaryKeyRelatedField(source='program', queryset=Program.objects.all())
    client_id = serializers.PrimaryKeyRelatedField(
        source='client',
        queryset=User.objects.all(),  # Temporarily allow any user as client
    )

    class Meta:
        model = Assignment
        fields = ['id', 'program_id', 'client_id', 'assigned_at', 'start_date']
        read_only_fields = ['assigned_at']


class LoggedSetSerializer(serializers.ModelSerializer):
    exercise_id = serializers.PrimaryKeyRelatedField(
        source='exercise',
        queryset=ProgramExercise.objects.all(),
        allow_null=True,
        required=False,
    )

    class Meta:
        model = LoggedSet
        fields = ['id', 'exercise_id', 'set_number', 'actual_reps', 'actual_load', 'rpe']


class SessionSerializer(serializers.ModelSerializer):
    logged_sets = LoggedSetSerializer(many=True, required=False)
    day_id = serializers.PrimaryKeyRelatedField(source='day', queryset=Day.objects.all(), allow_null=True, required=False)

    class Meta:
        model = Session
        fields = ['id', 'day_id', 'date', 'duration', 'completed', 'notes', 'logged_sets']

    def create(self, validated_data):
        logged_sets_data = validated_data.pop('logged_sets', [])
        session = Session.objects.create(**validated_data)
        for set_data in logged_sets_data:
            LoggedSet.objects.create(session=session, **set_data)
        return session

    def update(self, instance, validated_data):
        logged_sets_data = validated_data.pop('logged_sets', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if logged_sets_data is not None:
            instance.logged_sets.all().delete()
            for set_data in logged_sets_data:
                LoggedSet.objects.create(session=instance, **set_data)
        return instance

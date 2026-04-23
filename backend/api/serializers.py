from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth import get_user_model
from .models import (
    Assignment,
    Day,
    DeviceToken,
    LoggedSet,
    Program,
    ProgramExercise,
    ROLE_CHOICES,
    Session,
    User,
    Week,
)

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    role = serializers.ChoiceField(choices=ROLE_CHOICES, required=False, default='client')
    coach_join_code = serializers.CharField(write_only=True, required=False, allow_blank=True, max_length=16)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'role', 'coach_join_code']

    def validate_coach_join_code(self, value):
        return value.strip().upper()

    def validate(self, attrs):
        role = attrs.get('role', 'client')
        join_code = attrs.get('coach_join_code', '')

        if role == 'admin':
            raise serializers.ValidationError({'role': 'Admin registration is not available through this endpoint.'})

        if role in ['coach', 'admin'] and join_code:
            raise serializers.ValidationError({'coach_join_code': 'Coach join code is only valid for client registration.'})

        if role == 'client' and join_code:
            try:
                attrs['coach_user'] = User.objects.get(join_code=join_code, role__in=['coach', 'admin'])
            except User.DoesNotExist:
                raise serializers.ValidationError({'coach_join_code': 'Invalid coach join code.'})

        return attrs

    def create(self, validated_data):
        coach = validated_data.pop('coach_user', None)
        validated_data.pop('coach_join_code', None)
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email'),
            password=validated_data['password'],
            role=validated_data.get('role', 'client'),
            coach=coach,
        )
        return user


class UserSerializer(serializers.ModelSerializer):
    coach_id = serializers.PrimaryKeyRelatedField(source='coach', read_only=True)
    join_code = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'role', 'coach_id', 'join_code', 'avatar', 'status', 'subscription_tier']

    def get_join_code(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated and request.user.id == obj.id and obj.role in ['coach', 'admin']:
            return obj.join_code
        return None


class JoinCoachSerializer(serializers.Serializer):
    join_code = serializers.CharField(max_length=16)

    def validate_join_code(self, value):
        return value.strip().upper()

    def validate(self, attrs):
        join_code = attrs['join_code']
        try:
            attrs['coach'] = User.objects.get(join_code=join_code, role__in=['coach', 'admin'])
        except User.DoesNotExist:
            raise serializers.ValidationError({'join_code': 'Invalid coach join code.'})
        return attrs


class DeviceTokenUpsertSerializer(serializers.Serializer):
    token = serializers.CharField(max_length=255)
    platform = serializers.ChoiceField(choices=DeviceToken._meta.get_field('platform').choices)

    def validate_token(self, value):
        normalized_value = value.strip()
        if not normalized_value:
            raise serializers.ValidationError('Token cannot be blank.')
        return normalized_value

    def create(self, validated_data):
        user = self.context['request'].user
        return DeviceToken.upsert_for_user(
            user=user,
            token=validated_data['token'],
            platform=validated_data['platform'],
        )


class AuthTokenObtainPairSerializer(TokenObtainPairSerializer):
    device_token = serializers.CharField(required=False, write_only=True, max_length=255)
    device_platform = serializers.ChoiceField(
        required=False,
        write_only=True,
        choices=DeviceToken._meta.get_field('platform').choices,
    )

    def validate(self, attrs):
        device_token = attrs.pop('device_token', None)
        device_platform = attrs.pop('device_platform', None)

        if bool(device_token) != bool(device_platform):
            raise serializers.ValidationError(
                {'device_token': 'Both device_token and device_platform are required together.'}
            )

        data = super().validate(attrs)

        if device_token and device_platform:
            DeviceToken.upsert_for_user(
                user=self.user,
                token=device_token,
                platform=device_platform,
            )

        return data


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
        queryset=User.objects.filter(role='client'),
    )

    class Meta:
        model = Assignment
        fields = ['id', 'program_id', 'client_id', 'assigned_at', 'start_date']
        read_only_fields = ['assigned_at']

    def validate(self, attrs):
        request = self.context.get('request')
        user = request.user if request else None
        program = attrs['program']
        client = attrs['client']

        if client.role != 'client':
            raise serializers.ValidationError({'client_id': 'Only client users can receive assignments.'})

        if user and user.is_authenticated and user.role == 'coach':
            if program.coach_id != user.id:
                raise serializers.ValidationError({'program_id': 'You may only assign programs you own.'})
            if client.coach_id and client.coach_id != user.id:
                raise serializers.ValidationError({'client_id': 'This client belongs to a different coach.'})

        return attrs


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

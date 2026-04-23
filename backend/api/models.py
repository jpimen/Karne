import uuid
from datetime import timedelta
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone

ROLE_CHOICES = [
    ('admin', 'Admin'),
    ('coach', 'Coach'),
    ('client', 'Client'),
]

PROGRAM_STATUS_CHOICES = [
    ('draft', 'Draft'),
    ('published', 'Published'),
    ('archived', 'Archived'),
]

WORKOUT_SESSION_STATUS_CHOICES = [
    ('scheduled', 'Scheduled'),
    ('in_progress', 'In Progress'),
    ('completed', 'Completed'),
    ('missed', 'Missed'),
    ('skipped', 'Skipped'),
]

DEVICE_PLATFORM_CHOICES = [
    ('fcm', 'FCM'),
    ('apns', 'APNS'),
]

NOTIFICATION_STATUS_CHOICES = [
    ('pending', 'Pending'),
    ('sent', 'Sent'),
    ('failed', 'Failed'),
]


def generate_join_code():
    return uuid.uuid4().hex[:8].upper()


class User(AbstractUser):
    role = models.CharField(max_length=16, choices=ROLE_CHOICES, default='client')
    coach = models.ForeignKey(
        'self',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='clients',
        limit_choices_to={'role__in': ['coach', 'admin']},
    )
    join_code = models.CharField(blank=True, max_length=16, null=True, unique=True)
    avatar = models.URLField(blank=True, null=True)
    status = models.CharField(choices=[('novice', 'Novice'), ('pro', 'Pro'), ('elite', 'Elite')], default='novice', max_length=20)
    subscription_tier = models.CharField(blank=True, default='free', max_length=32)

    def _generate_unique_join_code(self):
        for _ in range(10):
            candidate = generate_join_code()
            if not type(self).objects.filter(join_code=candidate).exclude(pk=self.pk).exists():
                return candidate
        raise ValueError('Unable to generate a unique join code.')

    def save(self, *args, **kwargs):
        if self.role in {'coach', 'admin'} and not self.join_code:
            self.join_code = self._generate_unique_join_code()
        if self.role == 'client':
            self.join_code = None
        super().save(*args, **kwargs)

    def __str__(self):
        return self.username


class Program(models.Model):
    coach = models.ForeignKey(User, on_delete=models.CASCADE, related_name='programs')
    name = models.CharField(max_length=140)
    duration_weeks = models.PositiveSmallIntegerField(default=8)
    frequency_per_week = models.PositiveSmallIntegerField(default=4)
    goal = models.CharField(max_length=140, blank=True)
    description = models.TextField(blank=True)
    status = models.CharField(max_length=16, choices=PROGRAM_STATUS_CHOICES, default='draft')
    created_at = models.DateTimeField(auto_now_add=True)
    published_at = models.DateTimeField(blank=True, null=True)

    def save(self, *args, **kwargs):
        if self.status == 'published' and self.published_at is None:
            self.published_at = timezone.now()
        super().save(*args, **kwargs)

    def __str__(self):
        return f'{self.name} ({self.coach.username})'


class Week(models.Model):
    program = models.ForeignKey(Program, on_delete=models.CASCADE, related_name='weeks')
    week_number = models.PositiveSmallIntegerField()

    class Meta:
        unique_together = ('program', 'week_number')

    def __str__(self):
        return f'{self.program.name} - Week {self.week_number}'


class Day(models.Model):
    week = models.ForeignKey(Week, on_delete=models.CASCADE, related_name='days')
    day_number = models.PositiveSmallIntegerField()
    label = models.CharField(max_length=120, blank=True)

    class Meta:
        unique_together = ('week', 'day_number')

    def __str__(self):
        label = self.label if self.label else f'Day {self.day_number}'
        return f'{self.week.program.name} - {label}'


class ProgramExercise(models.Model):
    day = models.ForeignKey(Day, on_delete=models.CASCADE, related_name='exercises')
    order = models.PositiveSmallIntegerField(default=0)
    name = models.CharField(max_length=140)
    sets = models.PositiveSmallIntegerField(default=3)
    reps = models.CharField(max_length=32, blank=True)
    load = models.CharField(max_length=32, blank=True)
    rpe = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    intensity = models.CharField(max_length=32, blank=True)
    rest = models.CharField(max_length=32, blank=True)
    notes = models.TextField(blank=True)

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f'{self.name} ({self.day})'


class WorkoutPlan(models.Model):
    coach = models.ForeignKey(User, on_delete=models.CASCADE, related_name='workout_plans_created')
    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name='workout_plans')
    program = models.ForeignKey(Program, on_delete=models.CASCADE, related_name='workout_plans')
    start_date = models.DateField()
    end_date = models.DateField()
    assigned_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-assigned_at']

    def __str__(self):
        return f'{self.client.username} plan {self.program.name} ({self.start_date} to {self.end_date})'


class WorkoutSession(models.Model):
    workout_plan = models.ForeignKey(WorkoutPlan, on_delete=models.CASCADE, related_name='sessions')
    coach = models.ForeignKey(User, on_delete=models.CASCADE, related_name='assigned_workout_sessions')
    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name='workout_sessions')
    template_day = models.ForeignKey(Day, on_delete=models.SET_NULL, null=True, blank=True, related_name='workout_sessions')
    scheduled_date = models.DateField()
    week_number = models.PositiveSmallIntegerField()
    day_number = models.PositiveSmallIntegerField()
    status = models.CharField(max_length=16, choices=WORKOUT_SESSION_STATUS_CHOICES, default='scheduled')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['scheduled_date', 'id']
        indexes = [
            models.Index(fields=['client', 'scheduled_date']),
            models.Index(fields=['coach', 'status']),
        ]

    def __str__(self):
        return f'{self.client.username} workout {self.scheduled_date} ({self.status})'


class ExerciseSnapshot(models.Model):
    workout_session = models.ForeignKey(WorkoutSession, on_delete=models.CASCADE, related_name='exercise_snapshots')
    source_exercise = models.ForeignKey(ProgramExercise, on_delete=models.SET_NULL, null=True, blank=True, related_name='exercise_snapshots')
    order = models.PositiveSmallIntegerField(default=0)
    name = models.CharField(max_length=140)
    sets = models.PositiveSmallIntegerField(default=3)
    reps = models.CharField(max_length=32, blank=True)
    load = models.CharField(max_length=32, blank=True)
    rpe = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    intensity = models.CharField(max_length=32, blank=True)
    rest = models.CharField(max_length=32, blank=True)
    notes = models.TextField(blank=True)

    class Meta:
        ordering = ['order']
        unique_together = ('workout_session', 'order')

    def __str__(self):
        return f'{self.name} snapshot ({self.workout_session_id})'


class WorkoutLog(models.Model):
    workout_session = models.OneToOneField(WorkoutSession, on_delete=models.CASCADE, related_name='workout_log')
    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name='workout_logs')
    completed_at = models.DateTimeField(auto_now_add=True)
    duration = models.PositiveIntegerField(default=0)
    notes = models.TextField(blank=True)
    exercise_results = models.JSONField(default=list, blank=True)

    def __str__(self):
        return f'Workout log {self.workout_session_id}'


class Assignment(models.Model):
    program = models.ForeignKey(Program, on_delete=models.CASCADE, related_name='assignments')
    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name='assignments')
    assigned_at = models.DateTimeField(auto_now_add=True)
    start_date = models.DateField()

    class Meta:
        unique_together = ('program', 'client')

    def __str__(self):
        return f'{self.client.username} assigned {self.program.name}'


class Session(models.Model):
    client = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sessions')
    day = models.ForeignKey(Day, on_delete=models.SET_NULL, null=True, blank=True)
    date = models.DateField()
    duration = models.PositiveIntegerField(default=0)
    completed = models.BooleanField(default=False)
    notes = models.TextField(blank=True)

    def __str__(self):
        return f'{self.client.username} session {self.date}'


class LoggedSet(models.Model):
    session = models.ForeignKey(Session, on_delete=models.CASCADE, related_name='logged_sets')
    exercise = models.ForeignKey(ProgramExercise, on_delete=models.SET_NULL, null=True, blank=True)
    set_number = models.PositiveSmallIntegerField()
    actual_reps = models.CharField(max_length=32, blank=True)
    actual_load = models.CharField(max_length=32, blank=True)
    rpe = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)

    class Meta:
        ordering = ['set_number']

    def __str__(self):
        return f'{self.session} set {self.set_number}'


class DeviceToken(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='device_tokens')
    token = models.CharField(max_length=255)
    platform = models.CharField(max_length=16, choices=DEVICE_PLATFORM_CHOICES)
    created_at = models.DateTimeField(auto_now_add=True)
    last_seen_at = models.DateTimeField(default=timezone.now)

    class Meta:
        constraints = [
            models.UniqueConstraint(fields=['token', 'platform'], name='unique_device_token_platform'),
        ]
        indexes = [
            models.Index(fields=['user', 'platform']),
            models.Index(fields=['last_seen_at']),
        ]

    @classmethod
    def upsert_for_user(cls, *, user, token, platform):
        now = timezone.now()
        normalized_token = token.strip()
        device_token, _ = cls.objects.update_or_create(
            token=normalized_token,
            platform=platform,
            defaults={
                'user': user,
                'last_seen_at': now,
            },
        )
        return device_token

    @classmethod
    def stale_cutoff(cls):
        return timezone.now() - timedelta(days=60)

    @classmethod
    def active_for_user(cls, *, user):
        return cls.objects.filter(user=user, last_seen_at__gte=cls.stale_cutoff()).order_by('id')

    def __str__(self):
        return f'{self.user.username} {self.platform} token'


class Notification(models.Model):
    recipient = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    type = models.CharField(max_length=64)
    payload = models.JSONField(default=dict, blank=True)
    status = models.CharField(max_length=16, choices=NOTIFICATION_STATUS_CHOICES, default='pending')
    provider_response = models.JSONField(blank=True, default=dict)
    retry_count = models.PositiveSmallIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at', '-id']
        indexes = [
            models.Index(fields=['recipient', 'status']),
            models.Index(fields=['type', 'created_at']),
        ]

    def __str__(self):
        return f'{self.type} -> {self.recipient.username} ({self.status})'

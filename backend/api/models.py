import uuid
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


def generate_join_code():
    return uuid.uuid4().hex[:8].upper()


class User(AbstractUser):
    # role = models.CharField(max_length=16, choices=ROLE_CHOICES, default='client')
    # coach = models.ForeignKey(
    #     'self',
    #     on_delete=models.SET_NULL,
    #     null=True,
    #     blank=True,
    #     related_name='clients',
    # )
    # join_code = models.CharField(blank=True, max_length=16, null=True, unique=True)
    # created_at = models.DateTimeField(auto_now_add=True)
    avatar = models.URLField(blank=True, null=True)
    status = models.CharField(choices=[('novice', 'Novice'), ('pro', 'Pro'), ('elite', 'Elite')], default='novice', max_length=20)
    subscription_tier = models.CharField(blank=True, default='free', max_length=32)

    # def save(self, *args, **kwargs):
    #     if not self.join_code:
    #         self.join_code = generate_join_code()
    #     super().save(*args, **kwargs)

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

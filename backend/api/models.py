from django.contrib.auth.models import AbstractUser
from django.db import models

STATUS_CHOICES = [
    ('novice', 'Novice'),
    ('pro', 'Pro'),
    ('elite', 'Elite'),
]

PROGRAM_TYPES = [
    ('hypertrophy', 'Hypertrophy'),
    ('strength', 'Strength'),
    ('power', 'Power'),
    ('deload', 'Deload'),
]

EFFORT_TAGS = [
    ('elite', 'Elite Effort'),
    ('recovery', 'Recovery'),
    ('standard', 'Standard'),
]

class User(AbstractUser):
    avatar = models.URLField(blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='novice')
    subscription_tier = models.CharField(max_length=32, blank=True, default='free')

    def __str__(self):
        return self.username

class TrainingProgram(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='programs')
    name = models.CharField(max_length=120)
    week_current = models.PositiveIntegerField(default=1)
    week_total = models.PositiveIntegerField(default=8)
    program_type = models.CharField(max_length=24, choices=PROGRAM_TYPES, default='hypertrophy')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.name} ({self.user.username})'

class TrainingDay(models.Model):
    program = models.ForeignKey(TrainingProgram, on_delete=models.CASCADE, related_name='days')
    day_of_week = models.PositiveSmallIntegerField()
    day_label = models.CharField(max_length=120)

    def __str__(self):
        return f'{self.program.name} - {self.day_label}'

class Exercise(models.Model):
    name = models.CharField(max_length=120)
    category = models.CharField(max_length=80, blank=True)
    muscle_group = models.CharField(max_length=80, blank=True)

    def __str__(self):
        return self.name

class ProgramExercise(models.Model):
    day = models.ForeignKey(TrainingDay, on_delete=models.CASCADE, related_name='exercises')
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE, related_name='program_instances')
    sets = models.PositiveSmallIntegerField(default=3)
    reps = models.CharField(max_length=32, default='8')
    target_weight = models.FloatField(default=0.0)

    def __str__(self):
        return f'{self.day.day_label} - {self.exercise.name}'

class WorkoutSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sessions')
    date = models.DateField()
    duration_minutes = models.PositiveIntegerField(default=0)
    total_volume_kg = models.FloatField(default=0.0)
    effort_tag = models.CharField(max_length=20, choices=EFFORT_TAGS, default='standard')
    notes = models.TextField(blank=True)

    def __str__(self):
        return f'{self.user.username} session {self.date}'

class SessionSet(models.Model):
    session = models.ForeignKey(WorkoutSession, on_delete=models.CASCADE, related_name='sets')
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE)
    set_number = models.PositiveSmallIntegerField()
    reps = models.PositiveIntegerField()
    weight_kg = models.FloatField()
    rpe = models.FloatField(default=0.0)

    def __str__(self):
        return f'{self.session} set {self.set_number}'

class PersonalRecord(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='prs')
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE)
    weight_kg = models.FloatField()
    date_achieved = models.DateField()

    class Meta:
        unique_together = ('user', 'exercise')

    def __str__(self):
        return f'{self.user.username} PR {self.exercise.name} {self.weight_kg}kg'

from django.contrib import admin
from .models import (
    User,
    TrainingProgram,
    TrainingDay,
    Exercise,
    ProgramExercise,
    WorkoutSession,
    SessionSet,
    PersonalRecord,
)

admin.site.register(User)
admin.site.register(TrainingProgram)
admin.site.register(TrainingDay)
admin.site.register(Exercise)
admin.site.register(ProgramExercise)
admin.site.register(WorkoutSession)
admin.site.register(SessionSet)
admin.site.register(PersonalRecord)

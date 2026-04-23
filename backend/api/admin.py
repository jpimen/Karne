from django.contrib import admin
from .models import (
    Assignment,
    Day,
    DeviceToken,
    LoggedSet,
    Notification,
    Program,
    ProgramExercise,
    Session,
    User,
    Week,
    WorkoutLog,
    WorkoutPlan,
    WorkoutSession,
)

admin.site.register(User)
admin.site.register(Program)
admin.site.register(Week)
admin.site.register(Day)
admin.site.register(ProgramExercise)
admin.site.register(Assignment)
admin.site.register(Session)
admin.site.register(LoggedSet)
admin.site.register(WorkoutPlan)
admin.site.register(WorkoutSession)
admin.site.register(WorkoutLog)
admin.site.register(DeviceToken)
admin.site.register(Notification)

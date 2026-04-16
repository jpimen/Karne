from django.contrib import admin
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

admin.site.register(User)
admin.site.register(Program)
admin.site.register(Week)
admin.site.register(Day)
admin.site.register(ProgramExercise)
admin.site.register(Assignment)
admin.site.register(Session)
admin.site.register(LoggedSet)

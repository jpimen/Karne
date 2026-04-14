from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RegisterView,
    CurrentUserView,
    TrainingProgramViewSet,
    ExerciseViewSet,
    WorkoutSessionViewSet,
    dashboard,
    analytics_weekly_volume,
    analytics_prs,
)

router = DefaultRouter()
router.register('programs', TrainingProgramViewSet, basename='program')
router.register('exercises', ExerciseViewSet, basename='exercise')
router.register('sessions', WorkoutSessionViewSet, basename='session')

urlpatterns = [
    path('auth/register/', RegisterView.as_view(), name='auth_register'),
    path('auth/profile/', CurrentUserView.as_view(), name='auth_profile'),
    path('dashboard/', dashboard, name='dashboard'),
    path('analytics/weekly-volume/', analytics_weekly_volume, name='analytics_weekly_volume'),
    path('analytics/prs/', analytics_prs, name='analytics_prs'),
    path('', include(router.urls)),
]

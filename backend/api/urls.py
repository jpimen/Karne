from django.urls import include, path
from rest_framework.routers import DefaultRouter
from .views import (
    AssignmentViewSet,
    CurrentUserView,
    DeviceTokenUpsertView,
    JoinCoachView,
    ProgramViewSet,
    RegisterView,
    SessionViewSet,
    ClientViewSet,
    dashboard,
)

router = DefaultRouter()
router.register('programs', ProgramViewSet, basename='program')
router.register('clients', ClientViewSet, basename='client')
router.register('assignments', AssignmentViewSet, basename='assignment')
router.register('sessions', SessionViewSet, basename='session')

urlpatterns = [
    path('auth/register/', RegisterView.as_view(), name='auth_register'),
    path('auth/profile/', CurrentUserView.as_view(), name='auth_profile'),
    path('auth/join-coach/', JoinCoachView.as_view(), name='auth_join_coach'),
    path('client/device-token/', DeviceTokenUpsertView.as_view(), name='client_device_token'),
    path('dashboard/', dashboard, name='dashboard'),
    path('', include(router.urls)),
]

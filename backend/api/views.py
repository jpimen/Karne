from django.db.models import Count
from django.contrib.auth import get_user_model
from rest_framework import generics, permissions, viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response
from .models import Assignment, Program, Session, User
from .serializers import (
    AssignmentSerializer,
    ProgramSerializer,
    RegisterSerializer,
    SessionSerializer,
    UserSerializer,
)

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer


class CurrentUserView(generics.RetrieveAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user


class ProgramViewSet(viewsets.ModelViewSet):
    serializer_class = ProgramSerializer
    permission_classes = [permissions.AllowAny]  # Temporarily allow any for testing

    def get_queryset(self):
        user = self.request.user
        if user.is_authenticated:
            # Temporarily return all published programs for any authenticated user
            return Program.objects.filter(status='published').order_by('-created_at')
        return Program.objects.filter(status='published').order_by('-created_at')

    def perform_create(self, serializer):
        if self.request.user.role not in ['coach', 'admin']:
            raise PermissionDenied('Only coaches and admins can create programs.')
        serializer.save(coach=self.request.user)


class ClientViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role in ['coach', 'admin']:
            return User.objects.filter(coach=user, role='client')
        return User.objects.filter(pk=user.pk)


class AssignmentViewSet(viewsets.ModelViewSet):
    serializer_class = AssignmentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role in ['coach', 'admin']:
            return Assignment.objects.filter(program__coach=user).order_by('-assigned_at')
        return Assignment.objects.filter(client=user).order_by('-assigned_at')

    def perform_create(self, serializer):
        program = serializer.validated_data['program']
        if program.coach != self.request.user:
            raise PermissionDenied('You may only assign programs you own.')
        serializer.save()


class SessionViewSet(viewsets.ModelViewSet):
    serializer_class = SessionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'client':
            return Session.objects.filter(client=user).order_by('-date')
        return Session.objects.filter(client__coach=user).order_by('-date')

    def perform_create(self, serializer):
        if self.request.user.role != 'client':
            raise PermissionDenied('Only clients may create workout sessions.')
        serializer.save(client=self.request.user)


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def dashboard(request):
    user = request.user

    if user.role in ['coach', 'admin']:
        total_clients = User.objects.filter(coach=user, role='client').count()
        active_programs = Program.objects.filter(coach=user, status='published').count()
        programs_this_week = Program.objects.filter(coach=user, status='published').count()
        recent_activity = []
        assignments = Assignment.objects.filter(program__coach=user).order_by('-assigned_at')[:5]
        for assignment in assignments:
            recent_activity.append({
                'client': assignment.client.username,
                'program': assignment.program.name,
                'assigned_at': assignment.assigned_at,
            })

        return Response({
            'role': user.role,
            'summary': {
                'total_clients': total_clients,
                'active_programs': active_programs,
                'programs_this_week': programs_this_week,
            },
            'recent_activity': recent_activity,
        })

    assigned_program = Program.objects.filter(assignments__client=user, status='published').order_by('-created_at').first()
    return Response({
        'role': user.role,
        'assigned_program': ProgramSerializer(assigned_program).data if assigned_program else None,
        'recent_sessions': Session.objects.filter(client=user).order_by('-date')[:3].values('date', 'duration', 'completed'),
    })

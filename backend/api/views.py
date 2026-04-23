from django.contrib.auth import get_user_model
from django.db import transaction
from rest_framework import generics, permissions, viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView
from .models import Assignment, Program, Session, User
from .permissions import IsClient, IsCoachOrAdmin
from .services.assignment import assign_program_to_client
from .serializers import (
    AssignmentSerializer,
    AuthTokenObtainPairSerializer,
    DeviceTokenUpsertSerializer,
    JoinCoachSerializer,
    ProgramSerializer,
    RegisterSerializer,
    SessionSerializer,
    UserSerializer,
)

User = get_user_model()


class AuthTokenObtainPairView(TokenObtainPairView):
    serializer_class = AuthTokenObtainPairSerializer


class RegisterView(generics.CreateAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer


class CurrentUserView(generics.RetrieveAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user


class DeviceTokenUpsertView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated, IsClient]
    serializer_class = DeviceTokenUpsertSerializer

    def _upsert_token(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        token = serializer.save()
        return Response(
            {
                'id': token.id,
                'token': token.token,
                'platform': token.platform,
                'last_seen_at': token.last_seen_at,
            }
        )

    def post(self, request, *args, **kwargs):
        return self._upsert_token(request, *args, **kwargs)

    def patch(self, request, *args, **kwargs):
        return self._upsert_token(request, *args, **kwargs)


class JoinCoachView(generics.GenericAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = JoinCoachSerializer

    def post(self, request, *args, **kwargs):
        if request.user.role != 'client':
            raise PermissionDenied('Only client users can join a coach.')

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        request.user.coach = serializer.validated_data['coach']
        request.user.save(update_fields=['coach'])

        return Response(UserSerializer(request.user, context={'request': request}).data)


class ProgramViewSet(viewsets.ModelViewSet):
    serializer_class = ProgramSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsCoachOrAdmin()]
        return [permissions.IsAuthenticated()]

    def get_queryset(self):
        user = self.request.user
        queryset = Program.objects.order_by('-created_at')

        if user.role == 'admin':
            return queryset
        if user.role == 'coach':
            return queryset.filter(coach=user)
        return queryset.filter(assignments__client=user, status='published').distinct()

    def perform_create(self, serializer):
        serializer.save(coach=self.request.user)


class ClientViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'admin':
            return User.objects.filter(role='client').order_by('username')
        if user.role == 'coach':
            return User.objects.filter(coach=user, role='client').order_by('username')
        return User.objects.filter(pk=user.pk)


class AssignmentViewSet(viewsets.ModelViewSet):
    serializer_class = AssignmentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsCoachOrAdmin()]
        return [permissions.IsAuthenticated()]

    def get_queryset(self):
        user = self.request.user
        queryset = Assignment.objects.select_related('program', 'client').order_by('-assigned_at')
        if user.role == 'admin':
            return queryset
        if user.role == 'coach':
            return queryset.filter(program__coach=user)
        return queryset.filter(client=user)

    def perform_create(self, serializer):
        user = self.request.user
        program = serializer.validated_data['program']
        client = serializer.validated_data['client']
        start_date = serializer.validated_data['start_date']

        if user.role == 'coach' and program.coach_id != user.id:
            raise PermissionDenied('You may only assign programs you own.')

        if client.role != 'client':
            raise PermissionDenied('Only client users can receive assignments.')

        if user.role == 'coach' and client.coach_id and client.coach_id != user.id:
            raise PermissionDenied('This client belongs to a different coach.')

        if user.role == 'coach' and client.coach_id is None:
            client.coach = user
            client.save(update_fields=['coach'])

        with transaction.atomic():
            serializer.save()
            assign_program_to_client(
                coach=program.coach,
                client=client,
                program=program,
                start_date=start_date,
            )


class SessionViewSet(viewsets.ModelViewSet):
    serializer_class = SessionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsClient()]
        return [permissions.IsAuthenticated()]

    def get_queryset(self):
        user = self.request.user
        queryset = Session.objects.select_related('client', 'day').order_by('-date')
        if user.role == 'admin':
            return queryset
        if user.role == 'coach':
            return queryset.filter(client__coach=user)
        if user.role == 'client':
            return queryset.filter(client=user)
        return queryset.none()

    def perform_create(self, serializer):
        if self.request.user.role != 'client':
            raise PermissionDenied('Only clients may create workout sessions.')
        serializer.save(client=self.request.user)


@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def dashboard(request):
    user = request.user

    if user.role in ['coach', 'admin']:
        if user.role == 'admin':
            client_queryset = User.objects.filter(role='client')
            program_queryset = Program.objects.filter(status='published')
            assignments = Assignment.objects.select_related('client', 'program').order_by('-assigned_at')[:5]
        else:
            client_queryset = User.objects.filter(coach=user, role='client')
            program_queryset = Program.objects.filter(coach=user, status='published')
            assignments = Assignment.objects.select_related('client', 'program').filter(program__coach=user).order_by('-assigned_at')[:5]

        total_clients = client_queryset.count()
        active_programs = program_queryset.count()
        programs_this_week = program_queryset.count()
        recent_activity = []
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

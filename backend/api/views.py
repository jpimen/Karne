from django.db.models import Sum
from django.contrib.auth import get_user_model
from rest_framework import generics, viewsets, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from .models import TrainingProgram, Exercise, WorkoutSession, PersonalRecord
from .serializers import (
    UserSerializer,
    RegisterSerializer,
    TrainingProgramSerializer,
    ExerciseSerializer,
    WorkoutSessionSerializer,
    PersonalRecordSerializer,
)

User = get_user_model()

class RegisterView(generics.CreateAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer

class CurrentUserView(generics.RetrieveAPIView):
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user

class TrainingProgramViewSet(viewsets.ModelViewSet):
    serializer_class = TrainingProgramSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return TrainingProgram.objects.filter(user=self.request.user).order_by('-created_at')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class ExerciseViewSet(viewsets.ModelViewSet):
    serializer_class = ExerciseSerializer
    queryset = Exercise.objects.all()
    permission_classes = [permissions.IsAuthenticated]

class WorkoutSessionViewSet(viewsets.ModelViewSet):
    serializer_class = WorkoutSessionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return WorkoutSession.objects.filter(user=self.request.user).order_by('-date')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def dashboard(request):
    user = request.user
    total_volume = WorkoutSession.objects.filter(user=user).aggregate(total=Sum('total_volume_kg'))['total'] or 0
    session_count = WorkoutSession.objects.filter(user=user).count()
    prs = PersonalRecord.objects.filter(user=user).order_by('-weight_kg')[:4]
    current_program = TrainingProgram.objects.filter(user=user).order_by('-created_at').first()
    recent_sessions = WorkoutSession.objects.filter(user=user).order_by('-date')[:3]
    return Response({
        'user': UserSerializer(user).data,
        'summary': {
            'weekly_volume_kg': total_volume,
            'session_count': session_count,
        },
        'current_program': TrainingProgramSerializer(current_program).data if current_program else None,
        'prs': PersonalRecordSerializer(prs, many=True).data,
        'recent_sessions': WorkoutSessionSerializer(recent_sessions, many=True).data,
    })

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def analytics_weekly_volume(request):
    sessions = WorkoutSession.objects.filter(user=request.user).order_by('date')
    data = [
        {'date': session.date, 'volume': session.total_volume_kg}
        for session in sessions
    ]
    return Response(data)

@api_view(['GET'])
@permission_classes([permissions.IsAuthenticated])
def analytics_prs(request):
    prs = PersonalRecord.objects.filter(user=request.user).order_by('date_achieved')
    data = [
        {'exercise': pr.exercise.name, 'weight_kg': pr.weight_kg, 'date': pr.date_achieved}
        for pr in prs
    ]
    return Response(data)

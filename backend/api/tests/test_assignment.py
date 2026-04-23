from datetime import date, timedelta
from decimal import Decimal
from unittest.mock import patch

from django.db import DatabaseError
from django.test import TestCase

from api.models import (
    Day,
    ExerciseSnapshot,
    Program,
    ProgramExercise,
    User,
    Week,
    WorkoutPlan,
    WorkoutSession,
)
from api.services.assignment import assign_program_to_client


class AssignmentServiceTests(TestCase):
    def setUp(self):
        self.coach = User.objects.create_user(
            username='coach_phase2',
            email='coach@example.com',
            password='test-pass-123',
            role='coach',
        )
        self.client = User.objects.create_user(
            username='client_phase2',
            email='client@example.com',
            password='test-pass-123',
            role='client',
            coach=self.coach,
        )
        self.program = self._build_program_fixture(weeks=2, days_per_week=3)
        self.start_date = date(2026, 4, 20)

    def _build_program_fixture(self, *, weeks, days_per_week):
        program = Program.objects.create(
            coach=self.coach,
            name='Phase 2 Fixture Program',
            duration_weeks=weeks,
            frequency_per_week=days_per_week,
            status='published',
        )

        for week_number in range(1, weeks + 1):
            week = Week.objects.create(program=program, week_number=week_number)
            for day_number in range(1, days_per_week + 1):
                day = Day.objects.create(
                    week=week,
                    day_number=day_number,
                    label=f'Week {week_number} Day {day_number}',
                )
                ProgramExercise.objects.create(
                    day=day,
                    order=0,
                    name=f'Primary Lift W{week_number}D{day_number}',
                    sets=4,
                    reps='5',
                    load='75%',
                    rpe=Decimal('8.0'),
                    intensity='moderate',
                    rest='120s',
                    notes='Focus on bar speed.',
                )
                ProgramExercise.objects.create(
                    day=day,
                    order=1,
                    name=f'Accessory Lift W{week_number}D{day_number}',
                    sets=3,
                    reps='8',
                    load='65%',
                    rpe=Decimal('7.0'),
                    intensity='easy',
                    rest='90s',
                    notes='Controlled tempo.',
                )

        return program

    def test_assignment_creates_expected_sessions_and_snapshots(self):
        workout_plan = assign_program_to_client(
            coach=self.coach,
            client=self.client,
            program=self.program,
            start_date=self.start_date,
        )

        self.assertEqual(WorkoutPlan.objects.count(), 1)
        self.assertEqual(
            workout_plan.end_date,
            self.start_date + timedelta(days=9),
        )

        sessions = WorkoutSession.objects.filter(workout_plan=workout_plan).select_related('template_day').order_by('scheduled_date')
        self.assertEqual(sessions.count(), 6)

        expected_snapshot_count = ProgramExercise.objects.filter(day__week__program=self.program).count()
        actual_snapshot_count = ExerciseSnapshot.objects.filter(workout_session__workout_plan=workout_plan).count()
        self.assertEqual(actual_snapshot_count, expected_snapshot_count)

        for session in sessions:
            template_payload = list(
                session.template_day.exercises.order_by('order').values_list(
                    'order',
                    'name',
                    'sets',
                    'reps',
                    'load',
                    'rpe',
                    'intensity',
                    'rest',
                    'notes',
                )
            )
            snapshot_payload = list(
                session.exercise_snapshots.order_by('order').values_list(
                    'order',
                    'name',
                    'sets',
                    'reps',
                    'load',
                    'rpe',
                    'intensity',
                    'rest',
                    'notes',
                )
            )
            self.assertEqual(snapshot_payload, template_payload)

    def test_snapshot_remains_unchanged_after_template_mutation(self):
        workout_plan = assign_program_to_client(
            coach=self.coach,
            client=self.client,
            program=self.program,
            start_date=self.start_date,
        )

        initial_snapshot_payload = list(
            ExerciseSnapshot.objects.filter(workout_session__workout_plan=workout_plan)
            .order_by('id')
            .values_list('name', 'sets', 'reps', 'load', 'rpe', 'intensity', 'rest', 'notes')
        )

        ProgramExercise.objects.filter(day__week__program=self.program).update(
            name='Mutated Template Exercise',
            sets=10,
            reps='20',
            load='95%',
            rpe=Decimal('9.5'),
            intensity='hard',
            rest='30s',
            notes='This should not affect snapshots.',
        )

        mutated_snapshot_payload = list(
            ExerciseSnapshot.objects.filter(workout_session__workout_plan=workout_plan)
            .order_by('id')
            .values_list('name', 'sets', 'reps', 'load', 'rpe', 'intensity', 'rest', 'notes')
        )

        self.assertEqual(mutated_snapshot_payload, initial_snapshot_payload)
        self.assertFalse(
            ExerciseSnapshot.objects.filter(
                workout_session__workout_plan=workout_plan,
                name='Mutated Template Exercise',
            ).exists()
        )

    def test_assignment_rolls_back_on_database_error(self):
        original_create = WorkoutSession.objects.create
        create_call_count = {'count': 0}

        def create_then_fail(*args, **kwargs):
            create_call_count['count'] += 1
            if create_call_count['count'] == 2:
                raise DatabaseError('Simulated database failure during assignment.')
            return original_create(*args, **kwargs)

        with patch('api.services.assignment.WorkoutSession.objects.create', side_effect=create_then_fail):
            with self.assertRaises(DatabaseError):
                assign_program_to_client(
                    coach=self.coach,
                    client=self.client,
                    program=self.program,
                    start_date=self.start_date,
                )

        self.assertEqual(WorkoutPlan.objects.count(), 0)
        self.assertEqual(WorkoutSession.objects.count(), 0)
        self.assertEqual(ExerciseSnapshot.objects.count(), 0)

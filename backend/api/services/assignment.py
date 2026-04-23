from datetime import timedelta

from django.db import transaction

from api.models import Day, ExerciseSnapshot, WorkoutPlan, WorkoutSession
from api.signals import assignment_push_requested


class AssignmentError(ValueError):
    pass


def _build_assignment_push_payload(*, workout_plan, client, program):
    first_session = workout_plan.sessions.order_by('scheduled_date', 'id').first()
    deep_link = f'/session/{first_session.id}' if first_session else None
    return {
        'notification': {
            'title': 'New training plan assigned',
            'body': f'{program.name} is now available in your app.',
        },
        'data': {
            'event': 'assignment.created',
            'workout_plan_id': str(workout_plan.id),
            'program_id': str(program.id),
            'client_id': str(client.id),
            'first_session_id': str(first_session.id) if first_session else None,
            'deep_link': deep_link,
        },
    }


def _enqueue_assignment_notification_after_commit(*, workout_plan, client, program):
    payload = _build_assignment_push_payload(
        workout_plan=workout_plan,
        client=client,
        program=program,
    )

    def _enqueue():
        assignment_push_requested.send(
            sender=WorkoutPlan,
            recipient_id=client.id,
            notification_type='assignment_created',
            payload=payload,
        )

    transaction.on_commit(_enqueue)


def _validate_assignment(coach, client, program):
    if coach.role not in {'coach', 'admin'}:
        raise AssignmentError('Only coaches or admins can assign programs.')

    if client.role != 'client':
        raise AssignmentError('Only client users can receive assignments.')

    if coach.role == 'coach' and program.coach_id != coach.id:
        raise AssignmentError('Coaches can only assign their own programs.')

    if coach.role == 'coach' and client.coach_id and client.coach_id != coach.id:
        raise AssignmentError('This client belongs to a different coach.')


def _create_plan_for_client(*, coach, client, program, start_date):
    ordered_days = list(
        Day.objects.filter(week__program=program)
        .select_related('week')
        .prefetch_related('exercises')
        .order_by('week__week_number', 'day_number')
    )

    if not ordered_days:
        raise AssignmentError('Program must have at least one day before assignment.')

    if coach.role == 'coach' and client.coach_id is None:
        client.coach = coach
        client.save(update_fields=['coach'])

    workout_plan = WorkoutPlan.objects.create(
        coach=program.coach,
        client=client,
        program=program,
        start_date=start_date,
        end_date=start_date,
    )

    max_offset = 0
    for day in ordered_days:
        week_number = day.week.week_number
        offset_days = ((week_number - 1) * 7) + (day.day_number - 1)
        max_offset = max(max_offset, offset_days)

        session = WorkoutSession.objects.create(
            workout_plan=workout_plan,
            coach=program.coach,
            client=client,
            template_day=day,
            scheduled_date=start_date + timedelta(days=offset_days),
            week_number=week_number,
            day_number=day.day_number,
        )

        snapshots = [
            ExerciseSnapshot(
                workout_session=session,
                source_exercise=exercise,
                order=exercise.order,
                name=exercise.name,
                sets=exercise.sets,
                reps=exercise.reps,
                load=exercise.load,
                rpe=exercise.rpe,
                intensity=exercise.intensity,
                rest=exercise.rest,
                notes=exercise.notes,
            )
            for exercise in day.exercises.all().order_by('order')
        ]
        if snapshots:
            ExerciseSnapshot.objects.bulk_create(snapshots)

    workout_plan.end_date = start_date + timedelta(days=max_offset)
    workout_plan.save(update_fields=['end_date'])
    return workout_plan


def assign_program_to_client(*, coach, client, program, start_date, enqueue_notification=True):
    _validate_assignment(coach, client, program)
    with transaction.atomic():
        workout_plan = _create_plan_for_client(
            coach=coach,
            client=client,
            program=program,
            start_date=start_date,
        )
        if enqueue_notification:
            _enqueue_assignment_notification_after_commit(
                workout_plan=workout_plan,
                client=client,
                program=program,
            )
        return workout_plan


def assign_program_to_clients(*, coach, clients, program, start_date, enqueue_notification=True):
    workout_plans = []
    with transaction.atomic():
        for client in clients:
            _validate_assignment(coach, client, program)
            workout_plan = _create_plan_for_client(
                coach=coach,
                client=client,
                program=program,
                start_date=start_date,
            )
            workout_plans.append(workout_plan)
            if enqueue_notification:
                _enqueue_assignment_notification_after_commit(
                    workout_plan=workout_plan,
                    client=client,
                    program=program,
                )
    return workout_plans

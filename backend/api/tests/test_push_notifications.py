from datetime import date, timedelta
from decimal import Decimal
from unittest.mock import patch

from django.test import TestCase, override_settings
from django.utils import timezone
from rest_framework.test import APIClient

from api.models import Day, DeviceToken, Notification, Program, ProgramExercise, User, Week
from api.push import PushProviderError
from api.services.assignment import assign_program_to_client
from api.tasks import dispatch_notification, prune_stale_device_tokens


@override_settings(CELERY_TASK_ALWAYS_EAGER=True, CELERY_TASK_EAGER_PROPAGATES=True)
class PushNotificationPipelineTests(TestCase):
    def setUp(self):
        self.coach = User.objects.create_user(
            username='coach_phase3',
            email='coach_phase3@example.com',
            password='test-pass-123',
            role='coach',
        )
        self.client_user = User.objects.create_user(
            username='client_phase3',
            email='client_phase3@example.com',
            password='test-pass-123',
            role='client',
            coach=self.coach,
        )
        self.program = self._build_program_fixture()
        self.start_date = date(2026, 4, 20)

    def _build_program_fixture(self):
        program = Program.objects.create(
            coach=self.coach,
            name='Phase 3 Fixture Program',
            duration_weeks=1,
            frequency_per_week=1,
            status='published',
        )
        week = Week.objects.create(program=program, week_number=1)
        day = Day.objects.create(week=week, day_number=1, label='Day 1')
        ProgramExercise.objects.create(
            day=day,
            order=0,
            name='Back Squat',
            sets=4,
            reps='5',
            load='75%',
            rpe=Decimal('8.0'),
            intensity='moderate',
            rest='120s',
            notes='Drive with speed.',
        )
        return program

    def _assign_program(self):
        with self.captureOnCommitCallbacks(execute=True):
            assign_program_to_client(
                coach=self.coach,
                client=self.client_user,
                program=self.program,
                start_date=self.start_date,
            )

    @patch('api.push.adapters.FCMAdapter.send')
    def test_assignment_dispatches_to_fcm_adapter_with_deep_link_payload(self, mocked_send):
        mocked_send.return_value = {'success': 1}
        token = DeviceToken.objects.create(
            user=self.client_user,
            token='fcm-token-001',
            platform='fcm',
            last_seen_at=timezone.now(),
        )

        self._assign_program()

        mocked_send.assert_called_once()
        call_kwargs = mocked_send.call_args.kwargs
        self.assertEqual(call_kwargs['token'], token.token)
        self.assertEqual(call_kwargs['payload']['data']['event'], 'assignment.created')
        self.assertTrue(call_kwargs['payload']['data']['deep_link'].startswith('/session/'))

    @patch('api.push.adapters.APNsAdapter.send')
    def test_assignment_dispatches_to_apns_adapter(self, mocked_send):
        mocked_send.return_value = {'status': 'ok'}
        token = DeviceToken.objects.create(
            user=self.client_user,
            token='apns-token-001',
            platform='apns',
            last_seen_at=timezone.now(),
        )

        self._assign_program()

        mocked_send.assert_called_once()
        self.assertEqual(mocked_send.call_args.kwargs['token'], token.token)

    @patch('api.push.adapters.FCMAdapter.send')
    def test_integration_assignment_creates_sent_notification(self, mocked_send):
        mocked_send.return_value = {'success': 1}
        DeviceToken.objects.create(
            user=self.client_user,
            token='fcm-token-sent',
            platform='fcm',
            last_seen_at=timezone.now(),
        )

        self._assign_program()

        notification = Notification.objects.get(recipient=self.client_user, type='assignment_created')
        self.assertEqual(notification.status, 'sent')
        self.assertEqual(notification.retry_count, 0)
        self.assertTrue((notification.provider_response or {}).get('attempts'))

    @patch('api.push.adapters.FCMAdapter.send')
    def test_failed_dispatch_records_retry_count(self, mocked_send):
        mocked_send.side_effect = PushProviderError('Simulated push outage')
        DeviceToken.objects.create(
            user=self.client_user,
            token='fcm-token-fail',
            platform='fcm',
            last_seen_at=timezone.now(),
        )

        self._assign_program()

        notification = Notification.objects.get(recipient=self.client_user, type='assignment_created')
        self.assertEqual(notification.status, 'failed')
        self.assertGreaterEqual(notification.retry_count, 1)
        self.assertLessEqual(notification.retry_count, dispatch_notification.max_retries)
        attempts = (notification.provider_response or {}).get('attempts', [])
        self.assertGreaterEqual(len(attempts), 1)

    @patch('api.push.adapters.FCMAdapter.send')
    def test_stale_tokens_are_not_dispatched(self, mocked_send):
        DeviceToken.objects.create(
            user=self.client_user,
            token='fcm-token-stale',
            platform='fcm',
            last_seen_at=timezone.now() - timedelta(days=61),
        )

        self._assign_program()

        mocked_send.assert_not_called()
        notification = Notification.objects.get(recipient=self.client_user, type='assignment_created')
        self.assertEqual(notification.status, 'failed')

    def test_prune_task_removes_tokens_older_than_sixty_days(self):
        stale_token = DeviceToken.objects.create(
            user=self.client_user,
            token='stale-token-prune',
            platform='fcm',
            last_seen_at=timezone.now() - timedelta(days=61),
        )
        fresh_token = DeviceToken.objects.create(
            user=self.client_user,
            token='fresh-token-prune',
            platform='apns',
            last_seen_at=timezone.now() - timedelta(days=10),
        )

        deleted_count = prune_stale_device_tokens()

        self.assertEqual(deleted_count, 1)
        self.assertFalse(DeviceToken.objects.filter(pk=stale_token.pk).exists())
        self.assertTrue(DeviceToken.objects.filter(pk=fresh_token.pk).exists())


class DeviceTokenUpsertTests(TestCase):
    def setUp(self):
        self.client_api = APIClient()
        self.client_user = User.objects.create_user(
            username='client_device',
            email='client_device@example.com',
            password='test-pass-123',
            role='client',
        )

    def test_login_upserts_device_token(self):
        response = self.client_api.post(
            '/api/auth/login/',
            {
                'username': self.client_user.username,
                'password': 'test-pass-123',
                'device_token': 'fcm-login-token',
                'device_platform': 'fcm',
            },
            format='json',
        )

        self.assertEqual(response.status_code, 200)
        token = DeviceToken.objects.get(user=self.client_user, platform='fcm')
        self.assertEqual(token.token, 'fcm-login-token')

    def test_device_token_endpoint_upserts_last_seen(self):
        self.client_api.force_authenticate(user=self.client_user)
        first_response = self.client_api.post(
            '/api/client/device-token/',
            {'token': 'fcm-resume-token', 'platform': 'fcm'},
            format='json',
        )
        self.assertEqual(first_response.status_code, 200)

        original_last_seen = DeviceToken.objects.get(user=self.client_user, platform='fcm').last_seen_at

        second_response = self.client_api.patch(
            '/api/client/device-token/',
            {'token': 'fcm-resume-token', 'platform': 'fcm'},
            format='json',
        )
        self.assertEqual(second_response.status_code, 200)

        refreshed_token = DeviceToken.objects.get(user=self.client_user, platform='fcm')
        self.assertGreaterEqual(refreshed_token.last_seen_at, original_last_seen)

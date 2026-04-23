import logging
from datetime import timedelta

from celery import shared_task
from django.utils import timezone

from api.models import DeviceToken, Notification
from api.push import PushProviderError, get_adapter_for_platform

logger = logging.getLogger(__name__)


def _retry_delay_seconds(retries):
    return min(1800, 30 * (2**retries))


def _append_attempt(notification, attempt_payload):
    provider_response = notification.provider_response or {}
    attempts = provider_response.get('attempts', [])
    attempts.append(attempt_payload)
    provider_response['attempts'] = attempts
    notification.provider_response = provider_response


@shared_task(bind=True, max_retries=5, name='api.tasks.dispatch_notification')
def dispatch_notification(self, notification_id):
    try:
        notification = Notification.objects.select_related('recipient').get(pk=notification_id)
    except Notification.DoesNotExist:
        logger.warning('Notification %s was not found. Skipping dispatch.', notification_id)
        return

    now_iso = timezone.now().isoformat()
    try:
        tokens = list(DeviceToken.active_for_user(user=notification.recipient))
        if not tokens:
            _append_attempt(
                notification,
                {
                    'attempt': self.request.retries + 1,
                    'timestamp': now_iso,
                    'error': 'No active device tokens found.',
                },
            )
            notification.status = 'failed'
            notification.retry_count = self.request.retries
            notification.save(update_fields=['status', 'retry_count', 'provider_response'])
            return

        successful_dispatches = []
        failed_dispatches = []

        for token in tokens:
            adapter = get_adapter_for_platform(token.platform)
            try:
                provider_response = adapter.send(token=token.token, payload=notification.payload)
                successful_dispatches.append(
                    {
                        'token_id': token.id,
                        'platform': token.platform,
                        'response': provider_response,
                    }
                )
            except PushProviderError as exc:
                failed_dispatches.append(
                    {
                        'token_id': token.id,
                        'platform': token.platform,
                        'error': str(exc),
                    }
                )

        _append_attempt(
            notification,
            {
                'attempt': self.request.retries + 1,
                'timestamp': now_iso,
                'successful_dispatches': successful_dispatches,
                'failed_dispatches': failed_dispatches,
            },
        )

        if successful_dispatches:
            notification.status = 'sent'
            notification.save(update_fields=['status', 'provider_response'])
            return

        notification.status = 'failed'
        notification.retry_count = min(self.max_retries, self.request.retries + 1)
        notification.save(update_fields=['status', 'retry_count', 'provider_response'])

        if self.request.retries < self.max_retries:
            retry_delay = _retry_delay_seconds(self.request.retries)
            self.retry(countdown=retry_delay, throw=False)
    except Exception as exc:  # noqa: BLE001
        logger.exception('Unexpected error dispatching notification %s.', notification_id)
        _append_attempt(
            notification,
            {
                'attempt': self.request.retries + 1,
                'timestamp': timezone.now().isoformat(),
                'error': f'Unexpected error: {exc}',
            },
        )
        notification.status = 'failed'
        notification.retry_count = min(self.max_retries, self.request.retries + 1)
        notification.save(update_fields=['status', 'retry_count', 'provider_response'])
        if self.request.retries < self.max_retries:
            retry_delay = _retry_delay_seconds(self.request.retries)
            self.retry(countdown=retry_delay, throw=False)


@shared_task(name='api.tasks.prune_stale_device_tokens')
def prune_stale_device_tokens():
    cutoff = timezone.now() - timedelta(days=60)
    deleted_count, _ = DeviceToken.objects.filter(last_seen_at__lt=cutoff).delete()
    logger.info('Pruned %s stale device tokens older than %s.', deleted_count, cutoff.isoformat())
    return deleted_count

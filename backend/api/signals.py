import logging

from django.dispatch import Signal, receiver

from api.models import Notification

logger = logging.getLogger(__name__)

assignment_push_requested = Signal()


@receiver(assignment_push_requested)
def enqueue_assignment_push(sender, *, recipient_id, notification_type, payload, **kwargs):
    notification = Notification.objects.create(
        recipient_id=recipient_id,
        type=notification_type,
        payload=payload,
        status='pending',
    )
    try:
        from api.tasks import dispatch_notification

        dispatch_notification.delay(notification.id)
    except Exception as exc:  # noqa: BLE001
        logger.exception('Failed to enqueue notification %s.', notification.id)
        notification.status = 'failed'
        notification.retry_count = 0
        notification.provider_response = {
            'attempts': [
                {
                    'attempt': 1,
                    'error': f'Failed to enqueue task: {exc}',
                }
            ]
        }
        notification.save(update_fields=['status', 'retry_count', 'provider_response'])

import json
import os
from dataclasses import dataclass
from urllib import error, request


class PushProviderError(Exception):
    pass


@dataclass
class BasePushAdapter:
    platform: str

    def send(self, *, token, payload):
        raise NotImplementedError


class FCMAdapter(BasePushAdapter):
    def __init__(self):
        super().__init__(platform='fcm')

    def send(self, *, token, payload):
        server_key = os.getenv('FCM_SERVER_KEY', '').strip()
        if not server_key:
            raise PushProviderError('FCM server key is not configured.')

        data_payload = payload.get('data', {}) if isinstance(payload, dict) else {}
        notification_payload = payload.get('notification', {}) if isinstance(payload, dict) else {}
        request_body = json.dumps(
            {
                'to': token,
                'notification': notification_payload,
                'data': data_payload,
            }
        ).encode('utf-8')

        http_request = request.Request(
            url='https://fcm.googleapis.com/fcm/send',
            data=request_body,
            headers={
                'Authorization': f'key={server_key}',
                'Content-Type': 'application/json',
            },
            method='POST',
        )

        try:
            with request.urlopen(http_request, timeout=10) as response:
                response_data = response.read().decode('utf-8') or '{}'
                parsed_response = json.loads(response_data)
                if parsed_response.get('failure'):
                    raise PushProviderError(f'FCM dispatch failed: {parsed_response}')
                return parsed_response
        except error.HTTPError as exc:
            body = exc.read().decode('utf-8', errors='ignore')
            raise PushProviderError(f'FCM HTTP error {exc.code}: {body}') from exc
        except error.URLError as exc:
            raise PushProviderError(f'FCM network error: {exc.reason}') from exc


class APNsAdapter(BasePushAdapter):
    def __init__(self):
        super().__init__(platform='apns')

    def send(self, *, token, payload):
        raise PushProviderError('APNs adapter is not configured yet.')


def get_adapter_for_platform(platform):
    if platform == 'fcm':
        return FCMAdapter()
    if platform == 'apns':
        return APNsAdapter()
    raise PushProviderError(f'Unsupported push platform: {platform}')

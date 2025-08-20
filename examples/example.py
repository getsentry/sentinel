#!/usr/bin/env python3
"""
Sentry SDK Example - Python/Django (v2.35.0)
Demonstrates various Python syntax elements and Sentry integration patterns
"""

import os
import sys
import logging
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Union, Any
from dataclasses import dataclass
from functools import wraps
from enum import Enum

import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from sentry_sdk.integrations.logging import LoggingIntegration
from django.conf import settings
from django.http import JsonResponse, HttpRequest
from django.views import View
from django.core.cache import cache

SENTRY_DSN = os.getenv('SENTRY_DSN', 'https://your-key@sentry.io/0')
CACHE_TIMEOUT = 60 * 5  # 5 minutes
MAX_RETRIES = 3
API_VERSION = '2.0'

class ErrorLevel(Enum):
    DEBUG = 'debug'
    INFO = 'info'
    WARNING = 'warning'
    ERROR = 'error'
    CRITICAL = 'critical'

@dataclass
class SentryEvent:
    """Represents a Sentry error event"""
    event_id: str
    timestamp: datetime
    level: ErrorLevel
    message: str
    tags: Dict[str, str]
    user: Optional[Dict[str, Any]] = None
    extra: Optional[Dict[str, Any]] = None

    def to_dict(self) -> Dict[str, Any]:
        """Convert event to dictionary for JSON serialization"""
        return {
            'event_id': self.event_id,
            'timestamp': self.timestamp.isoformat(),
            'level': self.level.value,
            'message': self.message,
            'tags': self.tags,
            'user': self.user,
            'extra': self.extra
        }

def track_performance(operation_name: str):
    """Decorator to track function performance with Sentry"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            with sentry_sdk.start_transaction(op=operation_name, name=func.__name__):
                try:
                    result = func(*args, **kwargs)
                    sentry_sdk.set_tag('status', 'success')
                    return result
                except Exception as e:
                    sentry_sdk.set_tag('status', 'error')
                    sentry_sdk.capture_exception(e)
                    raise
        return wrapper
    return decorator

def retry_on_failure(max_attempts: int = MAX_RETRIES, delay: float = 1.0):
    """Retry decorator with exponential backoff"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exception = e
                    wait_time = delay * (2 ** attempt)
                    
                    sentry_sdk.capture_message(
                        f'Retry attempt {attempt + 1}/{max_attempts} for {func.__name__}',
                        level='warning'
                    )
                    
                    if attempt < max_attempts - 1:
                        time.sleep(wait_time)
                    else:
                        sentry_sdk.capture_exception(e)
            
            raise last_exception
        return wrapper
    return decorator

def init_sentry(environment: str = 'development') -> None:
    """Initialize Sentry SDK with custom configuration"""
    sentry_logging = LoggingIntegration(
        level=logging.INFO,
        event_level=logging.ERROR
    )
    
    sentry_sdk.init(
        dsn=SENTRY_DSN,
        integrations=[
            DjangoIntegration(),
            sentry_logging,
        ],
        traces_sample_rate=1.0,
        profiles_sample_rate=1.0,
        environment=environment,
        release=f"sentinel-theme@{API_VERSION}",
        before_send=before_send_filter,
    )
    
    sentry_sdk.set_tag('api_version', API_VERSION)
    sentry_sdk.set_tag('server_name', os.uname().nodename)

def before_send_filter(event: Dict[str, Any], hint: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Filter sensitive data before sending to Sentry"""
    sensitive_fields = ['password', 'credit_card', 'ssn', 'api_key']
    
    if 'extra' in event:
        for field in sensitive_fields:
            if field in event['extra']:
                event['extra'][field] = '[REDACTED]'
    
    if 'request' in event and event['request'].get('url', '').endswith('/health'):
        return None
    
    return event

class ErrorTrackingView(View):
    """API endpoint for error tracking operations"""
    
    @track_performance('api.error_tracking')
    def get(self, request: HttpRequest) -> JsonResponse:
        """Get recent errors from cache or database"""
        cache_key = f'errors:recent:{request.user.id}'
        cached_errors = cache.get(cache_key)
        
        if cached_errors:
            return JsonResponse({'errors': cached_errors, 'cached': True})
        
        try:
            errors = self._fetch_recent_errors(request.user)
            cache.set(cache_key, errors, CACHE_TIMEOUT)
            
            return JsonResponse({
                'errors': errors,
                'cached': False,
                'count': len(errors)
            })
        except Exception as e:
            sentry_sdk.capture_exception(e)
            return JsonResponse({'error': str(e)}, status=500)
    
    @retry_on_failure(max_attempts=3)
    def _fetch_recent_errors(self, user) -> List[Dict[str, Any]]:
        """Fetch recent errors for a user"""
        cutoff_date = datetime.now() - timedelta(days=7)
        
        mock_errors = [
            SentryEvent(
                event_id='abc123',
                timestamp=datetime.now(),
                level=ErrorLevel.ERROR,
                message='Sample error for testing',
                tags={'component': 'api', 'version': API_VERSION},
                user={'id': user.id, 'email': user.email}
            )
        ]
        
        return [error.to_dict() for error in mock_errors]

def capture_custom_error(
    message: str,
    level: Union[str, ErrorLevel] = ErrorLevel.ERROR,
    **kwargs
) -> str:
    """Capture a custom error to Sentry with additional context"""
    if isinstance(level, ErrorLevel):
        level = level.value
    
    with sentry_sdk.push_scope() as scope:
        for key, value in kwargs.items():
            scope.set_extra(key, value)
        
        event_id = sentry_sdk.capture_message(message, level=level)
        
        logging.info(f'Captured event {event_id}: {message}')
        return event_id

process_error = lambda x: sentry_sdk.capture_exception(x) if isinstance(x, Exception) else None

ErrorHandler = Union[
    callable[[Exception], None],
    callable[[Exception, Dict[str, Any]], str]
]

if __name__ == '__main__':
    environment = os.getenv('DJANGO_ENV', 'development')
    init_sentry(environment)
    
    try:
        result = 10 / 0
    except ZeroDivisionError as e:
        event_id = capture_custom_error(
            'Division by zero encountered',
            level=ErrorLevel.ERROR,
            numerator=10,
            denominator=0,
            operation='division'
        )
        print(f'Error captured with ID: {event_id}')

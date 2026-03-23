# API Timeout Fix Requirements

## Problem
Current timeout is hardcoded at 10 seconds. Need configurable timeout with retry logic and better logging.

## Solution Requirements

### 1. Configurable Timeout
- Read timeout from environment variable `API_TIMEOUT`
- Default to 30 seconds if not set
- Support values 5-300 seconds
- Validate config on startup

### 2. Retry Logic
- Retry failed requests up to 3 times
- Use exponential backoff: 1s, 2s, 4s
- Retry on: timeout, connection error, 5xx status
- Don't retry on: 4xx status, auth errors
- Max total time: timeout × retries

### 3. Logging
- Log every timeout event:
  - Request URL
  - Timeout duration
  - Attempt number (1, 2, 3)
  - Timestamp
  - Response status (if any)
- Use structured logging (JSON)
- Include correlation ID for tracing

### 4. Metrics
- Count total timeouts
- Count retries
- Track p50, p95, p99 latency
- Alert on timeout rate > 5%

## Implementation

```python
TIMEOUT = int(os.getenv('API_TIMEOUT', 30))
MAX_RETRIES = 3
BACKOFF = [1, 2, 4]

def make_request(url, attempt=1):
    try:
        response = requests.get(url, timeout=TIMEOUT)
        return response
    except Timeout:
        log_timeout(url, attempt)
        if attempt < MAX_RETRIES:
            time.sleep(BACKOFF[attempt-1])
            return make_request(url, attempt+1)
        else:
            raise
```

## Testing
- Test with different timeout values
- Test retry on timeout
- Test backoff timing
- Verify logging output
- Test max retries respected

# Session Management Requirements

## Overview
Define how sessions are managed for authenticated users.

## Requirements

### Active Sessions
1. **Token Refresh**
   - Refresh tokens periodically (every 15 min)
   - Don't interrupt user actions
   - Handle refresh failures gracefully

2. **Activity Tracking**
   - Track when user last interacted
   - Update timestamps on actions
   - Use for idle detection

3. **Connection**
   - Keep websocket alive for authenticated users
   - Send heartbeat pings
   - Reconnect if connection drops

### Expired Sessions
1. **Access Control**
   - Block API calls with expired tokens
   - Return 401 Unauthorized
   - Don't leak information about protected resources

2. **User Feedback**
   - Show "Session Expired" message
   - Redirect to login
   - Preserve intended destination for redirect after re-login

3. **Idle Timeout**
   - Set idle timeout to 30 minutes
   - Count time since last activity
   - Auto-logout idle users

## Implementation Notes
- Use JWT with sliding expiration
- Store session state in Redis
- Implement activity middleware to track interactions
- Use interceptors to handle 401 globally

## Testing
- Test token refresh flow
- Verify idle timeout triggers correctly
- Test expired session handling
- Verify websocket maintains connection

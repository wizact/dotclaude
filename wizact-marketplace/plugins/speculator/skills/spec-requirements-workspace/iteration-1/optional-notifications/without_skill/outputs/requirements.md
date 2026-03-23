# Notification System Requirements

## Goal
Build a multi-channel notification system with user-configurable preferences.

## Channels

### Email
- Send to user's registered email
- Use HTML templates
- Include unsubscribe link
- Track open/click rates

### SMS
- Send to verified phone number
- Plain text only, max 160 chars
- Cost consideration: limit frequency
- Carrier-dependent delivery

### Push Notifications
- Send to mobile app via FCM/APNS
- Rich notifications with images/actions
- Require device permission
- Handle token refresh

## User Preferences

Users can enable/disable each channel:
- Email: on/off
- SMS: on/off
- Push: on/off

Default: all enabled

Preferences stored in user profile table.

## Features

1. **Multi-Channel Delivery**
   - If user has multiple channels enabled, send to all
   - Each channel processes independently
   - Failures in one channel don't block others

2. **Rate Limiting**
   - Prevent notification spam
   - SMS: max 10/hour (cost control)
   - Email: max 50/day
   - Push: max 100/day

3. **Templates**
   - Different template for each channel
   - Email: rich HTML with branding
   - SMS: short plain text
   - Push: title + body + optional image

4. **Tracking**
   - Log all notification attempts
   - Track delivery status
   - Monitor opt-out rates

## Implementation Notes

- Use message queue for async delivery
- Retry failed deliveries (3x with backoff)
- Respect user opt-outs immediately
- GDPR/CAN-SPAM compliance

## Testing
- Test each channel independently
- Test multi-channel scenarios
- Verify rate limits work
- Check preference changes take effect

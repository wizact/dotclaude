# User Registration Requirements

## Overview
Allow new users to create accounts with email verification.

## Registration Flow

1. User fills form (email, password, confirm password)
2. Validate inputs
3. Check email not already registered
4. Create pending account
5. Send verification email
6. User clicks link in email
7. Account activated
8. User can login

## Validation Rules

### Email
- Must be valid email format
- Must not already exist in system
- Must be verifiable (can receive emails)

### Password
- Minimum 8 characters
- Contains uppercase letter
- Contains lowercase letter
- Contains number
- Contains special character
- Matches confirmation field

## Security Features

1. **Email Verification**
   - Send unique token via email
   - Token expires after 24 hours
   - Prevent login until verified

2. **CAPTCHA** (optional)
   - Show reCAPTCHA on form if enabled
   - Prevents bot registrations
   - Configurable on/off

3. **Duplicate Prevention**
   - Check if email exists before creating account
   - Show error: "Email already registered"
   - Suggest password reset if user forgot

4. **Rate Limiting**
   - Max 5 registration attempts per IP per hour
   - Prevents abuse

## Error Messages

- "Invalid email format"
- "Email already registered"
- "Password too weak" (with specific requirements)
- "Passwords don't match"
- "CAPTCHA verification failed"
- "Verification link expired"

## Database

- Store user with status: 'pending' or 'active'
- Store verification token with expiry
- Index on email for fast duplicate check

## Implementation Notes

- Use bcrypt for password hashing
- Generate secure random tokens (UUID)
- Send emails async via queue
- Log all registration attempts

## Testing
- Test valid registration flow
- Test duplicate email rejection
- Test weak password rejection
- Test expired verification links
- Test with/without CAPTCHA enabled

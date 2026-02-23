---
title: Password Hashing with bcrypt
impact: CRITICAL
impactDescription: Protects user passwords, prevents credential theft, meets security standards
tags: security, passwords, bcrypt, authentication, go
category: security
---

## Password Hashing with bcrypt

Use bcrypt with cost factor ≥12 for password hashing. Never store plaintext passwords.

**Incorrect (insecure password storage):**

```go
// DANGEROUS: Plaintext passwords
func CreateUser(email, password string) error {
    _, err := db.Exec("INSERT INTO users (email, password) VALUES ($1, $2)",
        email, password)  // Storing plaintext!
    return err
}

// DANGEROUS: MD5/SHA256 without salt
import "crypto/md5"

func HashPassword(password string) string {
    hash := md5.Sum([]byte(password))  // Fast, easily cracked
    return hex.EncodeToString(hash[:])
}

// DANGEROUS: Custom hashing
func CustomHash(password string) string {
    // Don't roll your own crypto!
}
```

**Correct (bcrypt with proper cost):**

```go
import "golang.org/x/crypto/bcrypt"

// Hash password with cost factor 14 (recommended: 12-14)
func HashPassword(password string) (string, error) {
    hash, err := bcrypt.GenerateFromPassword([]byte(password), 14)
    if err != nil {
        return "", err
    }
    return string(hash), nil
}

// Verify password
func VerifyPassword(hashedPassword, password string) error {
    return bcrypt.CompareHashAndPassword(
        []byte(hashedPassword),
        []byte(password),
    )
}

// Usage in user registration
func CreateUser(email, password string) error {
    hashedPassword, err := HashPassword(password)
    if err != nil {
        return fmt.Errorf("failed to hash password: %w", err)
    }

    _, err = db.ExecContext(ctx,
        "INSERT INTO users (email, password_hash) VALUES ($1, $2)",
        email, hashedPassword)
    return err
}

// Usage in authentication
func AuthenticateUser(email, password string) (User, error) {
    var user User
    err := db.QueryRowContext(ctx,
        "SELECT id, email, password_hash FROM users WHERE email = $1",
        email).Scan(&user.ID, &user.Email, &user.PasswordHash)

    if err != nil {
        return User{}, err
    }

    if err := VerifyPassword(user.PasswordHash, password); err != nil {
        return User{}, errors.New("invalid credentials")
    }

    return user, nil
}
```

**Benefits:**
- Protects passwords even if database is compromised
- Adaptive cost factor (increases with computing power)
- Salted automatically (unique hash per password)
- Industry standard (OWASP recommended)

**Cost Factor Guidelines:**
- **12**: Minimum acceptable
- **14**: Recommended for most applications
- **16+**: High-security applications (slower login)

**Never:**
- Store plaintext passwords
- Use fast hashes (MD5, SHA256) for passwords
- Roll your own password hashing

**Applies to**: All password storage without exception

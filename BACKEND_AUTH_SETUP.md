# Backend Authentication Setup - The Laboratory

## Overview
The backend authentication system is now fully functional with JWT-based token authentication for both user registration and login.

## Backend Structure

### API Endpoints

#### Authentication Endpoints
- **Register**: `POST /api/auth/register/`
  - Request: `{"username": "string", "email": "string", "password": "string"}`
  - Response: `{"username": "string", "email": "string"}`
  - Status: 201 Created

- **Login**: `POST /api/auth/login/`
  - Request: `{"username": "string", "password": "string"}`
  - Response: `{"access": "jwt_token", "refresh": "refresh_token"}`
  - Status: 200 OK

- **Current User Profile**: `GET /api/auth/profile/`
  - Headers: `Authorization: Bearer <access_token>`
  - Response: `{"id": "int", "username": "string", "email": "string", "avatar": "url", "status": "string", "subscription_tier": "string"}`
  - Status: 200 OK

### Database Configuration
- **Database**: SQLite (development)
- **Database File**: `db.sqlite3`
- **Models**:
  - `User` (Custom AbstractUser model)
    - Fields: `username`, `email`, `password`, `avatar`, `status`, `subscription_tier`
  - `Program` (Training programs)
  - `Session` (Training sessions)
  - `Assignment` (Assignment tracking)

### Security Features
- **JWT Authentication** using `djangorestframework-simplejwt`
- **CORS Enabled** for local development
- **Password Hashing** using Django's built-in password hashing
- **Token Expiration**:
  - Access Token: 15 minutes
  - Refresh Token: 7 days
  - Automatic token rotation enabled

### Django Settings Configuration
- **DEBUG**: True (development mode)
- **ALLOWED_HOSTS**: localhost, 127.0.0.1
- **Password Validators**: All Django defaults enabled
- **REST Framework**: JWT authentication required for all endpoints (except auth)

## Frontend Integration

### API Service (Dart)
The Flutter app communicates with the backend via `ApiService`:

```dart
// Register a new user
await apiService.register(username, email, password);

// Login
final response = await apiService.login(username, password);
final token = response['access'];
appProvider.setAuthenticated(true, token: token);

// Get current user profile
await apiService.getCurrentUser();
```

### Authentication Flow
1. User opens app → Splash screen shown
2. Onboarding carousel displayed (first-time users)
3. User can:
   - **Sign Up**: Create new account directly
   - **Login**: Use existing credentials
   - **Join with Code**: Enter invite code to join coach's program
4. After authentication:
   - JWT token stored in `AppProvider`
   - User redirected to home welcome screen
   - Token included in all subsequent API requests

### Screens Connected to Backend
- `athlete_signup_screen.dart`: Uses `register()` endpoint
- `athlete_account_creation_screen.dart`: Uses `register()` endpoint
- `athlete_login_screen.dart`: Uses `login()` endpoint
- All screens use `appProvider.apiService` for API calls

## Running the Backend Server

### Prerequisites
- Python 3.9+
- Django 5.2.6
- Django REST Framework 3.14+
- SimpleJWT authentication

### Start Server
```bash
cd backend
python manage.py runserver 127.0.0.1:8000
```

The server will be available at: `http://127.0.0.1:8000`

### Database Setup
Migrations are automatically applied on server start. To manually apply:
```bash
python manage.py migrate
```

## Testing the API

### Register a New User
```bash
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123"}'
```

### Login
```bash
curl -X POST http://127.0.0.1:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"password123"}'
```

### Get Current User Profile
```bash
curl -X GET http://127.0.0.1:8000/api/auth/profile/ \
  -H "Authorization: Bearer <access_token>"
```

## Error Handling

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| Username already exists | Duplicate user | Use a different username |
| Invalid email | Email format invalid | Provide valid email format |
| Password too short | Min 8 characters | Use password with 8+ characters |
| Invalid credentials | Wrong username/password | Check username and password |
| Token expired | Access token outdated | Use refresh token to get new access token |

## Token Management

### Access Token Refresh
```bash
curl -X POST http://127.0.0.1:8000/api/auth/token/refresh/ \
  -H "Content-Type: application/json" \
  -d '{"refresh":"<refresh_token>"}'
```

### Token Storage
- Tokens stored in `AppProvider` during runtime
- Automatically added to all authenticated requests
- Tokens NOT persisted to disk (session-based storage)

## Configuration Files

### Key Settings (`config/settings.py`)
- `REST_FRAMEWORK`: JWT authentication configuration
- `SIMPLE_JWT`: Token expiration and rotation settings
- `CORS_ALLOWED_ORIGINS`: Allowed origins for CORS
- `AUTH_USER_MODEL`: Custom user model reference

### Database Settings
- `USE_SQLITE`: Set to True for SQLite (default)
- `POSTGRES_*`: PostgreSQL settings available for production

## Security Considerations

1. **JWT Tokens**: Stateless authentication for scalability
2. **Password Hashing**: Django's PBKDF2 algorithm
3. **CORS Restrictions**: Only specified origins allowed
4. **Token Rotation**: Automatic refresh token rotation
5. **Error Messages**: Generic messages to prevent user enumeration

## Deployment Notes

For production deployment:
1. Set `DEBUG = False` in settings.py
2. Update `ALLOWED_HOSTS` with your domain
3. Use PostgreSQL instead of SQLite
4. Enable HTTPS and update CORS origins
5. Use environment variables for secrets
6. Set proper `SECRET_KEY` value
7. Configure email service for password recovery

## Troubleshooting

### Server Won't Start
```bash
# Check migrations
python manage.py check

# Apply pending migrations
python manage.py migrate

# Check for syntax errors
python manage.py check
```

### CORS Issues
- Verify request origin matches `CORS_ALLOWED_ORIGINS`
- Add your frontend URL to allowed origins in settings.py

### Authentication Failures
- Ensure token is included in Authorization header
- Check token hasn't expired (15 minutes)
- Use refresh token to get new access token

## Next Steps

1. **User Roles**: Implement coach/client role system
2. **Profile Pictures**: Upload and store user avatars
3. **Program Management**: Create and assign programs
4. **Session Logging**: Track workout sessions
5. **Email Verification**: Add email confirmation on signup
6. **Password Reset**: Implement forgot password flow

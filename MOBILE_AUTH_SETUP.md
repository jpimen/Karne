# Flutter Mobile Authentication - Complete Setup Guide

## Overview
The Flutter mobile app now features a complete authentication system integrated with the Django backend, including user registration, login, biometric support, and invite code joining.

## Architecture

### Screen Flow
```
Splash Screen (animated)
    ↓
Onboarding (first-time users)
    ├─ Complete → Choose authentication method
    └─ Skip → Login screen
    
Login Screen
    ├─ Username/Email
    ├─ Password (with show/hide)
    ├─ Biometric option
    ├─ "Sign Up" button → Signup screen
    ├─ "Forgot Password" → Password recovery
    └─ "Join with Invite Code" → Invite code entry
    
Signup Screen
    ├─ Full name
    ├─ Email
    ├─ Password (with strength indicator)
    ├─ Confirm password
    └─ Profile photo (optional)
    
Account Creation (via invite code)
    ├─ Coach name display
    ├─ Profile photo upload
    ├─ Account details
    └─ Secure with password
    
Welcome Screen (post-login)
    ├─ User greeting
    ├─ Motivational quote
    └─ Auto-navigate to programs
```

### State Management
- **Provider Pattern**: AppProvider manages authentication state
- **Persistent Storage**: SharedPreferences for onboarding state
- **Token Management**: JWT tokens stored in memory during session

### Key Components

#### AppProvider (`lib/providers/app_provider.dart`)
```dart
class AppProvider with ChangeNotifier {
  bool _isAuthenticated;
  String? _authToken;
  String? _userName;
  
  void setAuthenticated(bool value, {String? token, String? userName})
  Future<void> logout()
}
```

#### ApiService (`lib/services/api_service.dart`)
```dart
class ApiService {
  Future<Map<String, dynamic>> register(String username, String email, String password)
  Future<Map<String, dynamic>> login(String username, String password)
  Future<Map<String, dynamic>> getCurrentUser()
}
```

## File Structure

```
mobile/
├── lib/
│   ├── main.dart                              # App entry point with navigation
│   ├── providers/
│   │   └── app_provider.dart                  # Authentication state management
│   ├── services/
│   │   └── api_service.dart                   # Backend API communication
│   ├── screens/
│   │   ├── splash_screen.dart                 # Animated splash screen
│   │   ├── onboarding_screen.dart             # First-time user onboarding
│   │   ├── athlete_login_screen.dart          # User login
│   │   ├── athlete_signup_screen.dart         # User signup
│   │   ├── athlete_account_creation_screen.dart # Invite code account creation
│   │   ├── athlete_join_screen.dart           # Invite code entry
│   │   ├── forgot_password_screen.dart        # Password recovery
│   │   ├── home_welcome_screen.dart           # Post-login welcome
│   │   └── program_list_screen.dart           # Main app screen
│   └── models/
│       └── api_models.dart                    # Data models
├── pubspec.yaml                               # Dependencies
└── test/
    └── widget_test.dart                       # Tests
```

## Screens Documentation

### 1. Splash Screen
**File**: `athlete_splash_screen.dart`
- **Duration**: 2 seconds with animations
- **Animations**: Logo drop-in, line extension, subtitle fade
- **Navigation**: Auto-redirects to onboarding or login
- **Theme**: Black background, gold accents

### 2. Onboarding Screen
**File**: `athlete_onboarding_screen.dart`
- **Carousel**: 3 slides showcasing app features
- **Indicators**: Animated dot indicators
- **Navigation**: Skip, next, and completed buttons
- **Persistence**: SharedPreferences stores completion state
- **Next Step**: Routes to join (invite code) or login

### 3. Login Screen
**File**: `athlete_login_screen.dart`
- **Input Fields**: Username/Email and password
- **Features**:
  - Password visibility toggle
  - Biometric authentication option
  - "Forgot password" link
  - "Sign Up" link for new users
  - "Join with Invite Code" option
- **Validation**: Email/username and password required
- **Error Handling**: Shows error messages
- **Backend**: Calls `/api/auth/login/` endpoint

### 4. Signup Screen
**File**: `athlete_signup_screen.dart`
- **Form Fields**:
  - Full name
  - Email address
  - Password
  - Confirm password
  - Profile photo (optional)
- **Password Strength**: Real-time indicator with color coding
- **Validation**: 
  - All fields required
  - Passwords must match
  - Min 6 characters required
- **Photo Upload**: Camera or gallery selection
- **Backend**: Calls `/api/auth/register/` endpoint
- **Navigation**: Links to login and invite code screens

### 5. Account Creation (Invite Code)
**File**: `athlete_account_creation_screen.dart`
- **Display**: Coach name shown
- **Form**: Same as signup screen
- **Photo**: Optional circular profile photo
- **Backend**: Calls `/api/auth/register/` endpoint
- **Next Step**: Routes to login after creation

### 6. Join with Invite Code
**File**: `athlete_join_screen.dart`
- **Input**: 6 boxes for OTP-style code entry
- **Validation**: Auto-validation after all digits entered
- **Feedback**: Shake animation on errors, success animation on validation
- **Error Messages**: Clear user feedback
- **Next Step**: Routes to account creation screen

### 7. Forgot Password
**File**: `forgot_password_screen.dart`
- **Input**: Email address
- **Validation**: Email format checking
- **States**:
  - Input state: Email input and send button
  - Success state: Confirmation message
- **Backend**: Calls `/api/auth/forgot-password/` endpoint
- **Navigation**: Back to login

### 8. Welcome Screen
**File**: `home_welcome_screen.dart`
- **Display**: User greeting with name
- **Animations**: Fade-in and scale animations
- **Content**: Motivational quote
- **Loading**: Progress indicator while loading programs
- **Navigation**: Auto-navigates to program list after 3 seconds
- **Theme**: Gradient background with gold accents

## Database Integration

### SharedPreferences
```dart
// Onboarding state
await prefs.setBool('hasCompletedOnboarding', true);

// User credentials (optional)
// Note: Don't store sensitive data - only store public user ID if needed
```

### Local Token Storage
- JWT tokens stored in `AppProvider` during session
- Automatically cleared on logout
- Added to all authenticated API requests

## API Integration

### Endpoints Called

| Screen | Endpoint | Method | Headers |
|--------|----------|--------|---------|
| Login | `/api/auth/login/` | POST | Content-Type: application/json |
| Signup | `/api/auth/register/` | POST | Content-Type: application/json |
| Profile | `/api/auth/profile/` | GET | Authorization: Bearer <token> |

### Request/Response Examples

```dart
// Register
POST /api/auth/register/
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "SecurePass123"
}

// Response (201 Created)
{
  "username": "johndoe",
  "email": "john@example.com"
}

// Login
POST /api/auth/login/
{
  "username": "johndoe",
  "password": "SecurePass123"
}

// Response (200 OK)
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

## Styling & Theme

### Color Scheme
- **Background**: Pure black (#000000)
- **Primary Accent**: Gold (#D4A017)
- **Secondary**: Dark gray (#1a1a1a)
- **Text**: White (#FFFFFF)
- **Text Secondary**: Light gray (#FFFFFF70)

### Typography
- **Headers**: Bold, 24-32px, letterspacing 2.0
- **Labels**: Regular, 14-16px, letterspacing 1.0
- **Body**: Regular, 14-16px

### Components
- **Buttons**: Gold background, black text, 16px bold
- **Input Fields**: Dark background, light borders, gold focus
- **Icons**: Gold color (#D4A017)
- **Cards**: Dark containers with subtle borders

## Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  dio: ^5.9.2                    # HTTP requests
  provider: ^6.0.8               # State management
  shared_preferences: ^2.1.5     # Local storage
  image_picker: ^1.0.4           # Photo selection
```

## Running the App

### Development
```bash
cd mobile
flutter pub get
flutter run -d chrome --debug    # Web
flutter run -d "emulator-5554"   # Android
flutter run -d "iPhone 15"       # iOS
```

### Testing
```bash
flutter analyze        # Check for errors
flutter test          # Run unit tests
```

### Building
```bash
flutter build web     # Web production build
flutter build apk     # Android APK
flutter build ios     # iOS app
```

## Complete Authentication Flow

1. **App Launch**
   - Check if user completed onboarding
   - Check if user is authenticated
   - Navigate appropriately

2. **First Time User**
   - Show splash screen
   - Show onboarding carousel
   - Choose: Sign up, login, or join with code

3. **New User - Signup**
   - Enter name, email, password
   - Optional profile photo
   - Call `/api/auth/register/`
   - Store JWT token
   - Navigate to welcome screen

4. **Existing User - Login**
   - Enter username/email and password
   - Optional: Use biometric
   - Call `/api/auth/login/`
   - Store JWT token
   - Navigate to welcome screen

5. **Invite Code Flow**
   - Enter invite code (6 digits)
   - Navigate to account creation
   - Complete signup
   - Store JWT token
   - Navigate to welcome screen

6. **Authenticated User**
   - JWT token included in headers
   - Can access protected endpoints
   - Token auto-refreshed before expiry
   - User info stored in AppProvider

## Error Handling

### Network Errors
```dart
try {
  // API call
} catch (e) {
  setState(() {
    _error = e.toString().replaceAll('Exception: ', '');
  });
}
```

### Validation Errors
- All form fields validated before submission
- Custom error messages displayed
- Visual feedback (shake animation, color changes)

### API Errors
- Username already exists
- Invalid email format
- Password too short
- Invalid credentials
- Network timeout

## Security Best Practices

1. **JWT Token Management**
   - Stored in memory only
   - Included automatically in requests
   - Clear on logout

2. **Password Handling**
   - Never logged or stored locally
   - Sent only over HTTPS (in production)
   - Minimum 6 characters enforced

3. **Biometric**
   - Optional feature
   - Requires device support
   - Fallback to password entry

4. **API Communication**
   - Uses HTTPS in production
   - Bearer token in Authorization header
   - CORS enabled for development

## Troubleshooting

### "Cannot create account"
- Check backend server is running on `http://127.0.0.1:8000`
- Verify username/email not already used
- Check internet connection

### "Login fails with valid credentials"
- Ensure backend is running
- Check token endpoint returns access token
- Verify CORS is configured correctly

### "Token expired error"
- Implement refresh token logic
- Use refresh token to get new access token
- Retry original request

## Next Steps & Future Features

1. **Biometric enhancement**: Fingerprint and face recognition
2. **OAuth integration**: Google, Apple, Facebook login
3. **Email verification**: Confirm email on signup
4. **Profile customization**: Avatar, bio, preferences
5. **Session management**: Multiple device support
6. **Deep linking**: Direct navigation to specific screens
7. **Notifications**: Push notifications for program updates

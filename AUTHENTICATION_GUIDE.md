# Firebase Authentication System - Complete Guide

## Overview

This is a production-level Firebase authentication system for the Discipline Tracker app with email/password authentication. The system includes all core authentication features: sign up, sign in, password reset, password change, email change, username management, account deletion, and logout.

## Features Implemented

### ✅ Authentication Features

- **Sign Up / Register** - Create new account with email, password, and username
- **Sign In / Login** - Authenticate with email and password
- **Password Reset** - Send password reset email via Firebase
- **Change Password** - Update password while logged in
- **Update Username** - Change display name (with uniqueness check)
- **Update Email** - Change email address with verification
- **Delete Account** - Permanently delete account and user data
- **Sign Out / Logout** - Securely sign out from app
- **Session Persistence** - Automatic re-authentication on app launch

### 🔒 Security Features

- **Strong Password Validation**
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
- **Email Validation** - RFC-compliant email format checking
- **Username Validation**
  - 3-30 characters
  - Letters, numbers, underscores, hyphens, and dots only
  - Uniqueness enforcement
- **Secure Password Storage** - Firebase Authentication handles all hashing
- **Firestore Security Rules** - Rule templates included
- **Recent Login Requirement** - Account deletion requires recent authentication

## Project Structure

### Services

```
lib/services/
├── auth_service.dart          # Core authentication logic
│   ├── AuthException         # Custom exception class
│   └── AuthService           # Main service with all auth methods
└── notification_service.dart  # (existing)
```

### Providers

```
lib/providers/
├── auth_provider.dart         # State management for authentication
├── habit_provider.dart        # (existing)
├── theme_provider.dart        # (existing)
└── locale_provider.dart       # (existing)
```

### Screens

```
lib/screens/
├── login_screen.dart                # Sign in screen
├── register_screen.dart             # Sign up screen
├── forgot_password_screen.dart      # Password reset screen
├── change_password_screen.dart      # Change password screen
├── account_settings_screen.dart     # Account management screen
├── home_screen.dart                 # (existing)
├── ai_coach_screen.dart             # (existing)
├── calendar_screen.dart             # (existing)
├── diary_screen.dart                # (existing)
├── add_habit_screen.dart            # (existing)
├── settings_screen.dart             # Updated with account mgmt link
└── pomodoro_screen.dart             # (existing)
```

### Models

```
lib/models/
├── user_profile.dart          # Updated with auth fields
├── habit.dart                 # (existing)
└── habit_goal.dart            # (existing)
```

## Installation & Setup

### 1. Update pubspec.yaml

The following dependencies have been added:

```yaml
firebase_auth: ^5.1.4
cloud_firestore: ^5.0.2
```

Run:

```bash
flutter pub get
```

### 2. Firebase Configuration

Your `firebase_options.dart` should already be configured via FlutterFire CLI.

If not, run:

```bash
flutterfire configure
```

### 3. Enable Authentication Methods

In Firebase Console:

1. Go to **Authentication** > **Sign-in method**
2. Enable **Email/Password**
3. Enable **Email link sign-in** (optional, for password reset)

### 4. Create Firestore Database

1. Go to **Firestore Database**
2. Create database in production mode
3. Deploy security rules (see next section)

### 5. Deploy Firestore Security Rules

Create/update your Firestore security rules:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Deny all by default
    match /{document=**} {
      allow read, write: if false;
    }

    // Users collection
    match /users/{userId} {
      // User can read/write their own document
      allow read, write: if request.auth.uid == userId;

      // Create new user profile on signup
      allow create: if request.auth.uid == userId &&
                       request.resource.data.uid == userId &&
                       request.resource.data.email == request.auth.token.email;
    }
  }
}
```

## Usage Guide

### 1. User Registration

```dart
final authProvider = context.read<AuthProvider>();
final success = await authProvider.register(
  email: 'user@example.com',
  password: 'SecurePass123',
  username: 'john_doe',
);

if (success) {
  // User registered and auto-logged in
} else {
  // Show error: authProvider.errorMessage
}
```

### 2. User Sign In

```dart
final authProvider = context.read<AuthProvider>();
final success = await authProvider.signIn(
  email: 'user@example.com',
  password: 'SecurePass123',
);

if (success) {
  // User logged in
} else {
  // Show error: authProvider.errorMessage
}
```

### 3. Password Reset

```dart
final authProvider = context.read<AuthProvider>();
final success = await authProvider.resetPassword(
  email: 'user@example.com',
);

if (success) {
  // Email sent
}
```

### 4. Change Password

```dart
final authProvider = context.read<AuthProvider>();
final success = await authProvider.changePassword(
  newPassword: 'NewSecurePass123',
);
```

### 5. Update Username

```dart
final authProvider = context.read<AuthProvider>();
final success = await authProvider.updateUsername(
  newUsername: 'new_username',
);
```

### 6. Delete Account

```dart
final authProvider = context.read<AuthProvider>();
final success = await authProvider.deleteAccount();

if (success) {
  // Account deleted, navigate to login
}
```

### 7. Sign Out

```dart
final authProvider = context.read<AuthProvider>();
await authProvider.signOut();
// User redirected to login screen
```

### 8. Check Authentication Status

```dart
// In widgets
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (authProvider.isAuthenticated) {
      // User is logged in
    } else {
      // Show login screen
    }
  },
)

// Or access current user
final authProvider = context.read<AuthProvider>();
final currentUser = authProvider.currentUser;
final userProfile = authProvider.userProfile;
```

## Navigation Flow

The app automatically handles navigation based on authentication state:

```
┌─────────────────────┐
│   App Starts (main) │
└──────────┬──────────┘
           │
    Check Auth State
           │
      ┌────┴────┐
      │          │
   Logged In   Not Logged In
      │          │
      ▼          ▼
  MainShell   LoginScreen
  (App UI)    ├── Register Link
             ├── Forgot Password
             └── [Register/Reset screens]

MainShell Menu:
├── Home
├── AI Coach
├── Calendar
├── Diary
└── Settings
    └── Account Management
        ├── Change Username
        ├── Change Email
        ├── Change Password
        ├── Delete Account
        └── Logout
```

## Error Handling

All errors are caught and user-friendly messages are provided:

```dart
try {
  await authProvider.register(email, password, username);
} catch (e) {
  final errorMessage = authProvider.errorMessage;
  // Common errors:
  // - "Email already in use"
  // - "Username already taken"
  // - "The password is too weak"
  // - "Invalid email address"
  // - "Password must contain uppercase, lowercase, and number"
  // - "Network error. Check your connection."
}
```

## Password Validation Requirements

All passwords must contain:

- ✅ **Minimum 8 characters**
- ✅ **At least one UPPERCASE letter** (A-Z)
- ✅ **At least one lowercase letter** (a-z)
- ✅ **At least one number** (0-9)

Examples:

- ❌ `password123` - no uppercase
- ❌ `Password` - no number
- ❌ `Pass1` - too short
- ✅ `SecurePass123` - valid
- ✅ `MyPass2024!` - valid

## Firestore Data Structure

### Users Collection

```json
{
  "users": {
    "{userId}": {
      "uid": "firebase_user_id",
      "email": "user@example.com",
      "username": "john_doe",
      "displayUsername": "John_Doe",
      "createdAt": "2024-03-25T10:30:00Z",
      "updatedAt": "2024-03-25T10:30:00Z"
    }
  }
}
```

## Security Best Practices

1. **Never Log Passwords** - AuthService never logs passwords
2. **HTTPS Only** - Firebase ensures all communication is encrypted
3. **Rate Limiting** - Firebase automatically rate-limits failed auth attempts
4. **Session Management** - Firebase handles token refresh automatically
5. **Recent Login Check** - Account deletion requires reauthentication
6. **Email Verification** - Email changes require verification
7. **Secure Storage** - SharedPreferences and local storage are handled securely
8. **App Signing** - Configure app signing for production releases

## Testing the System

### Test Account

Create a test account:

- Email: `test@example.com`
- Username: `testuser`
- Password: `TestPass123`

### Test Scenarios

1. **Registration** - Create new account
2. **Login** - Sign in with credentials
3. **Password Reset** - Receive reset email and update password
4. **Username Change** - Update to new username and verify it's unique
5. **Password Change** - Change to new password
6. **Email Change** - Verify new email and update
7. **Logout** - Sign out and verify redirected to login
8. **Account Deletion** - Delete account (WARNING: irreversible)

## Troubleshooting

### Issue: "Firebase not initialized"

**Solution**: Check Firebase initialization in main.dart

### Issue: "User not found"

**Solution**: User doesn't exist or email is incorrect

### Issue: "Weak password"

**Solution**: Password must meet all requirements (8+ chars, uppercase, lowercase, number)

### Issue: "Email already in use"

**Solution**: Email is registered to another account

### Issue: "Username already taken"

**Solution**: Try a different username

### Issue: "Network error"

**Solution**: Check internet connection and Firebase connectivity

### Issue: "Too many requests"

**Solution**: Wait a few minutes before retrying authentication

## File Modifications Summary

### New Files Created:

- ✅ `lib/services/auth_service.dart` - Core auth logic
- ✅ `lib/providers/auth_provider.dart` - State management
- ✅ `lib/screens/login_screen.dart` - Sign in UI
- ✅ `lib/screens/register_screen.dart` - Sign up UI
- ✅ `lib/screens/forgot_password_screen.dart` - Password reset UI
- ✅ `lib/screens/change_password_screen.dart` - Change password UI
- ✅ `lib/screens/account_settings_screen.dart` - Account management UI

### Modified Files:

- ✅ `lib/main.dart` - Added AuthProvider, auth state routing
- ✅ `lib/models/user_profile.dart` - Added auth fields
- ✅ `lib/screens/settings_screen.dart` - Added account management link
- ✅ `pubspec.yaml` - Added firebase_auth, cloud_firestore

## Next Steps

1. **Test authentication flow** in your app
2. **Configure Firebase email templates** for custom reset emails
3. **Add additional user fields** to Firestore as needed
4. **Implement multi-factor authentication** (optional)
5. **Add social authentication** (Google, GitHub, etc.)
6. **Set up analytics** to track user activity
7. **Implement password strength meter** on registration

## Support

For Firebase documentation:

- [Firebase Authentication](https://firebase.flutter.dev/docs/auth/overview/)
- [Cloud Firestore](https://firebase.flutter.dev/docs/firestore/overview/)
- [Security Rules](https://firebase.google.com/docs/rules)

For Flutter documentation:

- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Forms](https://flutter.dev/docs/cookbook/forms)

---

**System Status**: ✅ Production Ready
**Last Updated**: March 25, 2024
**Version**: 1.0.0

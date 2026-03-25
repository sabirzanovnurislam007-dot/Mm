# Firebase Authentication - Quick Reference

## Core Classes

### AuthService (lib/services/auth_service.dart)

Main service for all authentication operations. Handles Firebase Auth and Firestore.

```dart
// Instance (Singleton)
final authService = AuthService();

// Methods
Future<User?> register({required String email, required String password, required String username})
Future<User?> signIn({required String email, required String password})
Future<void> resetPassword({required String email})
Future<void> changePassword({required String newPassword})
Future<void> changeEmail({required String newEmail})
Future<void> updateUsername({required String newUsername})
Future<UserProfile?> getUserProfile()
Future<void> deleteAccount()
Future<void> signOut()

// Properties
User? get currentUser
bool get isAuthenticated
Stream<User?> get authStateChanges
```

### AuthProvider (lib/providers/auth_provider.dart)

State management for authentication using Provider pattern.

```dart
// Properties
User? get currentUser
UserProfile? get userProfile
bool get isLoading
String? get errorMessage
bool get isAuthenticated
bool get isPasswordVisible
Stream<User?> get authStateChanges

// Methods
Future<bool> register({required String email, required String password, required String username})
Future<bool> signIn({required String email, required String password})
Future<bool> resetPassword({required String email})
Future<bool> changePassword({required String newPassword})
Future<bool> changeEmail({required String newEmail})
Future<bool> updateUsername({required String newUsername})
Future<bool> deleteAccount()
Future<void> signOut()
void togglePasswordVisibility()
void clearError()
```

## Common Code Patterns

### Check if User is Logged In

```dart
// In build():
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (authProvider.isAuthenticated) {
      return MainApp();
    } else {
      return LoginScreen();
    }
  },
)

// Or direct access:
final isLoggedIn = context.read<AuthProvider>().isAuthenticated;
```

### Show Loading & Error States

```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    return Column(
      children: [
        if (authProvider.isLoading)
          CircularProgressIndicator(),
        if (authProvider.errorMessage != null)
          Text(authProvider.errorMessage, style: TextStyle(color: Colors.red)),
      ],
    );
  },
)
```

### Access Current User

```dart
final authProvider = context.read<AuthProvider>();
final user = authProvider.currentUser;
final profile = authProvider.userProfile;

print('Email: ${user?.email}');
print('Username: ${profile?.username}');
print('UID: ${user?.uid}');
```

### Perform Auth Action

```dart
final authProvider = context.read<AuthProvider>();
final success = await authProvider.register(
  email: emailController.text,
  password: passwordController.text,
  username: usernameController.text,
);

if (success) {
  // Action succeeded
  Navigator.of(context).pushReplacementNamed('/home');
} else {
  // Show error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(authProvider.errorMessage ?? 'Failed')),
  );
}
```

## Error Handling

Common error messages to expect:

```
// Registration
"Email already in use"
"Username already taken"
"Password must contain uppercase, lowercase, and number"
"Username must be at least 3 characters"

// Sign In
"User does not exist"
"Incorrect password"
"Too many attempts. Try again later."

// Validation
"Invalid email format"
"Email cannot be empty"
"Password cannot be empty"
"Password must be at least 8 characters"

// Network
"Network error. Check your connection."
"Operation failed. Check your connection."

// Account Operations
"User not authenticated"
"Failed to change password"
"Please sign out and sign in again before deleting your account"
```

## Password Requirements

All passwords must contain:

- 8+ characters
- At least 1 UPPERCASE letter
- At least 1 lowercase letter
- At least 1 number

Valid examples: `SecurePass123`, `MyP@ssw0rd`, `Password2024`

## Username Requirements

- 3-30 characters
- Can contain: letters, numbers, underscores, hyphens, dots
- Must be unique
- Case-insensitive (stored as lowercase)

Valid examples: `john_doe`, `user.123`, `jane-smith`

## Screen Navigation

```
LoginScreen
├── [Password] → ForgotPasswordScreen → LoginScreen
└── [Sign Up] → RegisterScreen
                ├── [Back] → LoginScreen
                └── [Sign Up] → MainApp

AccountSettingsScreen (from Settings)
├── [Change Username] → Dialog edit
├── [Change Email] → Dialog edit
├── [Change Password] → ChangePasswordScreen
├── [Delete Account] → Confirmation → LoginScreen
└── [Log Out] → Confirmation → LoginScreen
```

## Security Best Practices

✅ DO:

- Validate input on client side
- Show loading states during async operations
- Clear sensitive data on logout
- Use environment variables for config
- Test authentication thoroughly
- Monitor Firebase console for suspicious activity
- Keep dependencies updated

❌ DON'T:

- Store passwords in plain text
- Log sensitive information
- Bypass security rules in development
- Use weak passwords for testing
- Store tokens in local storage insecurely
- Skip email verification
- Disable security rules for testing

## Testing

### Test Credentials (for development)

```
Email: test@example.com
Password: TestPass123
Username: testuser
```

### Test Cases

1. Register new account
2. Login with correct password
3. Login with wrong password
4. Reset forgotten password
5. Change password while logged in
6. Update username
7. Change email
8. Delete account (WARNING: irreversible)
9. Logout and verify

## Common Imports

```dart
// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Project specific
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'models/user_profile.dart';
```

## Debugging

### Check Current Auth State

```dart
final user = FirebaseAuth.instance.currentUser;
print('Current user: ${user?.email}');
print('UID: ${user?.uid}');
print('Verified: ${user?.emailVerified}');
```

### Listen to Auth Changes

```dart
FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user == null) {
    print('User signed out');
  } else {
    print('User: ${user.email}');
  }
});
```

### Query User Profile

```dart
final uid = FirebaseAuth.instance.currentUser?.uid;
if (uid != null) {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  print(doc.data());
}
```

## Firebase Console Quick Links

- Create account: https://firebase.google.com/
- Authentication: Go to project > Authentication > Users
- Firestore: Go to project > Firestore Database > Collections
- Cloud Logs: https://console.cloud.google.com/logs
- Usage/Billing: Go to project > Settings > Billing

## Version Information

- Firebase Auth: 5.1.4
- Cloud Firestore: 5.0.2
- Provider: 6.1.2
- Flutter: 3.9.2+

## Support & Resources

- [Firebase Auth Documentation](https://firebase.flutter.dev/docs/auth/overview/)
- [Cloud Firestore Documentation](https://firebase.flutter.dev/docs/firestore/overview/)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Flutter Forms](https://flutter.dev/docs/cookbook/forms)

---

Last Updated: March 25, 2024

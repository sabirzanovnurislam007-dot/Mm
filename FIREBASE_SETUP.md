# Firebase Setup Instructions

## Quick Start

This guide will walk you through setting up Firebase for the Discipline Tracker authentication system.

## Prerequisites

- Firebase account (https://firebase.google.com)
- Google Cloud Project (created when you set up Firebase)
- FlutterFire CLI installed (`flutter pub global activate flutterfire_cli`)

## Step-by-Step Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Create a project** or **Add project**
3. Enter project name: `DisciplineTracker` (or your preferred name)
4. Select your country/region
5. Click **Create project**
6. Wait for setup to complete

### 2. Register Your App with Firebase

#### For iOS:

1. In Firebase Console, click **iOS** icon (or **Add app** > **iOS**)
2. Bundle ID: `com.example.discipline_tracker` (or your actual bundle ID from `ios/Runner/Info.plist`)
3. Click **Register app**
4. Download `GoogleService-Info.plist`
5. Open Xcode: `open ios/Runner.xcworkspace`
6. Drag `GoogleService-Info.plist` into Xcode (Runner project, not Pods)
7. Ensure it's added to all targets (Runner)
8. Click **Next** in Firebase Console

#### For Android:

1. In Firebase Console, click **Android** icon (or **Add app** > **Android**)
2. Package name: Get from `android/app/build.gradle` (usually `com.example.discipline_tracker`)
3. SHA-1 fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the SHA-1 value
4. Click **Register app**
5. Download `google-services.json`
6. Place it in `android/app/`
7. Click **Next** in Firebase Console

### 3. Initialize Firebase with FlutterFire

Run FlutterFire CLI to auto-generate Firebase configuration:

```bash
flutterfire configure
```

This will:

- Ask which platforms to configure (select iOS and Android if applicable)
- Ask which Firebase features to use (select **Authentication** and **Firestore**)
- Auto-generate `lib/firebase_options.dart`
- Update your iOS and Android configs

If you get errors, ensure you're in the project root directory.

### 4. Enable Authentication Methods

1. In Firebase Console, go to **Build** > **Authentication**
2. Click **Get started**
3. Click on **Email/Password** provider
4. Toggle **Enable**
5. (Optional) Enable **Email Link Sign-in** for passwordless sign-in
6. Click **Save**

### 5. Create Firestore Database

1. In Firebase Console, go to **Build** > **Firestore Database**
2. Click **Create database**
3. Select your region (choose closest to your users)
4. Select **Start in production mode**
5. Click **Create**
6. Wait for database initialization

### 6. Deploy Firestore Security Rules

1. Install Firebase CLI if not already installed:

   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:

   ```bash
   firebase login
   ```

3. Initialize Firebase in your project:

   ```bash
   firebase init firestore
   ```

   - Select your Firebase project
   - For `firestore.rules`, answer `N` (we'll use our custom rules)
   - For `firestore.indexes.json`, answer `N`

4. Replace `firestore.rules` with the provided rules:

   ```bash
   cp firestore.rules firestore.rules.backup  # backup current
   # Copy the contents from the provided firestore.rules file
   ```

5. Deploy the rules:

   ```bash
   firebase deploy --only firestore:rules
   ```

   Expected output:

   ```
   ✔ Deployed rules for database (default) to cloud.firestore
   ```

### 7. Verify Setup

1. Test basic authentication by running the app:

   ```bash
   flutter pub get
   flutter run
   ```

2. Try to register a new account
3. Check Firebase Console > **Authentication** to see the new user
4. Check Firebase Console > **Firestore Database** to see the user profile document created

## Configuration Files

After setup, you should have:

- ✅ `lib/firebase_options.dart` - Auto-generated
- ✅ `android/app/google-services.json` - Downloaded from Firebase
- ✅ `ios/Runner/GoogleService-Info.plist` - Downloaded from Firebase
- ✅ `firestore.rules` - Provided in this repo

## Environment Variables (Optional)

For more security, consider using environment variables:

```bash
# Create .env file
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_APP_ID=your-app-id
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
```

Then load in `main.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  // ... rest of initialization
}
```

## Troubleshooting

### Issue: `FlutterError: Firebase.initializeApp() not called before usage`

**Solution**: Check `main.dart` has:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Issue: `PlatformException: PERMISSION_DENIED`

**Solution**: Check your Firestore security rules are deployed correctly:

```bash
firebase deploy --only firestore:rules
```

### Issue: iOS build fails with Firebase

**Solution**:

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: Android build fails

**Solution**:

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

### Issue: Can't find GoogleService-Info.plist

**Solution**: Make sure it's added to Xcode (visible in project tree) and configured for the Runner target.

## Next Steps

After successful setup:

1. ✅ Test the authentication system with the app
2. ✅ Create test accounts and verify they appear in Firebase Console
3. ✅ Test password reset functionality
4. ✅ Configure email templates in Firebase Console > **Authentication** > **Email Templates**
5. ✅ Set up custom domain for auth emails (optional)
6. ✅ Enable additional security features (optional)

## Firebase Console URLs

- **Main Project**: https://console.firebase.google.com/project/YOUR_PROJECT_ID
- **Authentication**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication
- **Firestore**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore
- **Cloud Functions**: https://console.firebase.google.com/project/YOUR_PROJECT_ID/functions

Replace `YOUR_PROJECT_ID` with your actual project ID.

## Important Security Notes

⚠️ **Before Publishing to Production:**

1. Enable Google reCAPTCHA in Firebase for login/signup
2. Configure email templates with your brand
3. Set up backup and recovery options
4. Enable multi-factor authentication (optional)
5. Review and test all security rules thoroughly
6. Monitor analytics and security alerts
7. Set up proper logging and monitoring
8. Review Firebase pricing and usage limits

## Support

- **Firebase Documentation**: https://firebase.google.com/docs
- **Flutter Firebase Docs**: https://firebase.flutter.dev/
- **Firestore Security Rules**: https://firebase.google.com/docs/rules
- **Google Cloud Console**: https://console.cloud.google.com

---

**Date**: March 25, 2024
**Status**: Ready for Configuration

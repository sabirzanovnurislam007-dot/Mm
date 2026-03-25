import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  @override
  String toString() => message;
}

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Register a new user with email and password
  Future<User?> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Validate inputs
      _validateEmail(email);
      _validatePassword(password);
      _validateUsername(username);

      // Check if username is already taken
      final existingUser = await _firestore
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw AuthException(message: 'Username already taken');
      }

      // Create user account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException(message: 'Failed to create user account');
      }

      // Update display name in Firebase Auth
      await user.updateDisplayName(username.trim());
      await user.reload();

      // Create user profile in Firestore
      await _createUserProfile(user.uid, email, username);

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(message: 'Registration failed: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _validateEmail(email);

      if (password.isEmpty) {
        throw AuthException(message: 'Password cannot be empty');
      }

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(message: 'Sign in failed: ${e.toString()}');
    }
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    try {
      _validateEmail(email);

      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Failed to send reset email: ${e.toString()}',
      );
    }
  }

  /// Change password (requires user to be logged in)
  Future<void> changePassword({required String newPassword}) async {
    try {
      if (currentUser == null) {
        throw AuthException(message: 'User not authenticated');
      }

      _validatePassword(newPassword);

      await currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Failed to change password: ${e.toString()}',
      );
    }
  }

  /// Change user email
  Future<void> changeEmail({required String newEmail}) async {
    try {
      if (currentUser == null) {
        throw AuthException(message: 'User not authenticated');
      }

      _validateEmail(newEmail);

      // Update email in Firebase Auth
      await currentUser!.verifyBeforeUpdateEmail(newEmail.trim());

      // Update email in Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'email': newEmail.trim(),
      });
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(message: 'Failed to change email: ${e.toString()}');
    }
  }

  /// Update username
  Future<void> updateUsername({required String newUsername}) async {
    try {
      if (currentUser == null) {
        throw AuthException(message: 'User not authenticated');
      }

      _validateUsername(newUsername);

      // Check if new username is already taken
      final existingUser = await _firestore
          .collection('users')
          .where('username', isEqualTo: newUsername.toLowerCase())
          .where('uid', isNotEqualTo: currentUser!.uid)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw AuthException(message: 'Username already taken');
      }

      // Update in Firebase Auth
      await currentUser!.updateDisplayName(newUsername.trim());

      // Update in Firestore
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'username': newUsername.toLowerCase().trim(),
        'displayUsername': newUsername.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await currentUser!.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        message: 'Failed to update username: ${e.toString()}',
      );
    }
  }

  /// Get user profile from Firestore
  Future<UserProfile?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return UserProfile(
        uid: data['uid'] ?? '',
        email: data['email'] ?? '',
        username: data['displayUsername'] ?? currentUser!.displayName ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      throw AuthException(
        message: 'Failed to fetch user profile: ${e.toString()}',
      );
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile({
    String? username,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (currentUser == null) {
        throw AuthException(message: 'User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (username != null) {
        _validateUsername(username);
        updateData['username'] = username.toLowerCase().trim();
        updateData['displayUsername'] = username.trim();
      }

      if (additionalData != null) {
        updateData.addAll(additionalData);
      }

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update(updateData);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(message: 'Failed to update profile: ${e.toString()}');
    }
  }

  /// Delete user account (WARNING: This is irreversible)
  Future<void> deleteAccount() async {
    try {
      if (currentUser == null) {
        throw AuthException(message: 'User not authenticated');
      }

      final uid = currentUser!.uid;

      // Delete user data from Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Delete user from Firebase Auth
      await currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw AuthException(
          message:
              'Please sign out and sign in again before deleting your account',
          code: e.code,
        );
      }
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(message: 'Failed to delete account: ${e.toString()}');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(message: 'Failed to sign out: ${e.toString()}');
    }
  }

  // --- Private Helper Methods ---

  /// Create user profile document in Firestore
  Future<void> _createUserProfile(
    String uid,
    String email,
    String username,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email.trim(),
        'username': username.toLowerCase().trim(),
        'displayUsername': username.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AuthException(
        message: 'Failed to create user profile: ${e.toString()}',
      );
    }
  }

  /// Validate email format
  void _validateEmail(String email) {
    if (email.isEmpty) {
      throw AuthException(message: 'Email cannot be empty');
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      throw AuthException(message: 'Invalid email format');
    }
  }

  /// Validate password strength
  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw AuthException(message: 'Password cannot be empty');
    }
    if (password.length < 8) {
      throw AuthException(message: 'Password must be at least 8 characters');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      throw AuthException(message: 'Password must contain uppercase letter');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      throw AuthException(message: 'Password must contain lowercase letter');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      throw AuthException(message: 'Password must contain a number');
    }
  }

  /// Validate username
  void _validateUsername(String username) {
    if (username.isEmpty) {
      throw AuthException(message: 'Username cannot be empty');
    }
    if (username.length < 3) {
      throw AuthException(message: 'Username must be at least 3 characters');
    }
    if (username.length > 30) {
      throw AuthException(message: 'Username must not exceed 30 characters');
    }
    if (!RegExp(r'^[a-zA-Z0-9_\-.]+$').hasMatch(username)) {
      throw AuthException(
        message:
            'Username can only contain letters, numbers, underscores, hyphens, and dots',
      );
    }
  }

  /// Handle Firebase Auth exceptions
  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(message: 'User does not exist');
      case 'wrong-password':
        return AuthException(message: 'Incorrect password');
      case 'email-already-in-use':
        return AuthException(message: 'Email already in use');
      case 'invalid-email':
        return AuthException(message: 'Invalid email address');
      case 'operation-not-allowed':
        return AuthException(message: 'Email/password sign in is disabled');
      case 'weak-password':
        return AuthException(message: 'Password is too weak');
      case 'too-many-requests':
        return AuthException(
          message: 'Too many attempts. Try again later.',
          code: e.code,
        );
      case 'network-request-failed':
        return AuthException(
          message: 'Network error. Check your connection.',
          code: e.code,
        );
      case 'invalid-credential':
        return AuthException(message: 'Invalid credentials');
      default:
        return AuthException(message: 'Authentication error: ${e.message}');
    }
  }
}

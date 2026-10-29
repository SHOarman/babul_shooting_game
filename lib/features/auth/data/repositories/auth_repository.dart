import 'package:firebase_auth/firebase_auth.dart';
import '../datasources/firebase_auth_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuthService _service;

  AuthRepository({FirebaseAuthService? service})
      : _service = service ?? FirebaseAuthService();

  /// Stream of UserModel based on auth state
  Stream<UserModel?> get authStateChanges {
    return _service.authStateChanges.map((User? user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  /// Get current user model if logged in
  UserModel? getCurrentUser() {
    final User? user = _service.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  /// Register new user and send verification email
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final User user = await _service.signUpWithEmailPassword(
        email: email,
        password: password,
        name: name,
      );
      return UserModel.fromFirebaseUser(user, displayName: name);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  /// Login user (only if email is verified)
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final User user = await _service.signInWithEmailPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  /// Resend verification email
  Future<void> resendVerificationEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _service.resendVerificationEmail(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Check if user has verified email
  Future<bool> checkEmailVerified({
    required String email,
    required String password,
  }) async {
    try {
      return await _service.checkEmailVerified(email: email, password: password);
    } catch (_) {
      return false;
    }
  }

  /// Sign in with Google (Google accounts are automatically verified)
  Future<UserModel> signInWithGoogle() async {
    try {
      final User user = await _service.signInWithGoogle();
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  /// Send reset password link
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _service.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _service.signOut();
    } catch (e) {
      throw 'Could not sign out: ${e.toString()}';
    }
  }

  /// User-friendly Firebase error messages
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-not-verified':
        return 'Your email is not verified yet! Please check your Gmail (including Spam folder) and click the verification link.';
      case 'email-already-in-use':
        return 'This email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6-8 characters.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

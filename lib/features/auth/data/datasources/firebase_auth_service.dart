import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase User
  User? get currentUser => _auth.currentUser;

  /// Sign up with Email and Password
  Future<User> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    final UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Could not create user account.',
      );
    }

    // Update display name
    await user.updateDisplayName(name.trim());

    return user;
  }

  /// Sign in with Email and Password
  Future<User> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final User? user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'User account not found.',
      );
    }

    return user;
  }

  /// Resend verification email
  Future<void> resendVerificationEmail({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final User? user = credential.user;
    if (user != null) {
      await user.sendEmailVerification();
      await _auth.signOut();
    }
  }

  /// Check if email is verified
  Future<bool> checkEmailVerified({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final User? user = credential.user;
    if (user == null) return false;
    await user.reload();
    final bool isVerified = _auth.currentUser?.emailVerified ?? false;
    await _auth.signOut();
    return isVerified;
  }

  /// Sign in with Google (Google accounts are pre-verified)
  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw 'Google Sign-In was cancelled by user.';
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential credentialResult = await _auth.signInWithCredential(credential);
    final User? user = credentialResult.user;
    if (user == null) {
      throw 'Google Sign-In failed to authenticate user.';
    }

    return user;
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign Out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

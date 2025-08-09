import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Manages the state and business logic for user authentication tasks.
/// Exposes simple methods that return Future<bool> so UI can navigate on success.
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Returns current Firebase user (null if signed out).
  User? get currentUser => _auth.currentUser;

  /// Stream to listen to auth state changes (e.g., for a wrapper widget).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ------------------------------
  // Login
  // ------------------------------
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError('');
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      // Provide user-friendly messages based on common error codes.
      final msg = _mapSignInError(e.code);
      _setError(msg, autoClearAfter: const Duration(seconds: 3));
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred. Please try again.', autoClearAfter: const Duration(seconds: 3));
      _setLoading(false);
      return false;
    }
  }

  // ------------------------------
  // Sign up
  // ------------------------------
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    _setError('');
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      // If you want the user to continue signed in, remove the signOut.
      // Keeping signOut() mirrors your previous behavior (forcing fresh login).
      await _auth.signOut();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      final msg = _mapSignUpError(e.code);
      _setError(msg, autoClearAfter: const Duration(seconds: 3));
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred. Please try again.', autoClearAfter: const Duration(seconds: 3));
      _setLoading(false);
      return false;
    }
  }

  // ------------------------------
  // Password reset
  // ------------------------------
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _setError('');
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      final msg = (e.code == 'user-not-found')
          ? 'No user found for that email.'
          : 'An error occurred. Please try again.';
      _setError(msg, autoClearAfter: const Duration(seconds: 3));
      _setLoading(false);
      return false;
    } catch (_) {
      _setError('An unexpected error occurred. Please try again.', autoClearAfter: const Duration(seconds: 3));
      _setLoading(false);
      return false;
    }
  }

  // ------------------------------
  // Logout
  // ------------------------------
  Future<void> logout() async {
    _setLoading(true);
    _setError('');
    try {
      await _auth.signOut();
      _setLoading(false);
    } catch (_) {
      // Even if sign out fails, clear loading so UI is responsive.
      _setError('Failed to sign out. Please try again.', autoClearAfter: const Duration(seconds: 3));
      _setLoading(false);
    }
  }

  // ------------------------------
  // Helpers
  // ------------------------------
  void clearErrorMessage() {
    if (_errorMessage.isNotEmpty) {
      _errorMessage = '';
      notifyListeners();
    }
  }

  // Internal state setters with optional auto-clear for transient errors.
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _setError(String message, {Duration? autoClearAfter}) {
    _errorMessage = message;
    notifyListeners();
    if (message.isNotEmpty && autoClearAfter != null) {
      Future.delayed(autoClearAfter, () {
        // Only clear if it's still the same message to avoid racing.
        if (_errorMessage == message) {
          _errorMessage = '';
          notifyListeners();
        }
      });
    }
  }

  String _mapSignInError(String code) {
    switch (code) {
      case 'invalid-email':
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential': // unified error on some platforms
        return 'Your email or password is incorrect.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  String _mapSignUpError(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'An error occurred. Please check your details.';
    }
  }
}

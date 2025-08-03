import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Manages the state and business logic for all user authentication tasks.
class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String _errorMessage = '';

  /// Indicates if an authentication process is currently running.
  bool get isLoading => _isLoading;

  /// Holds the latest error message. Empty if no error.
  String get errorMessage => _errorMessage;

  // --- Login Method ---
  Future<bool> login(String email, String password) async {
    // ... (existing login code)
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException {
      // 1. Define the error message
      const String errorToShow = 'Your email or password is incorrect.';
      _errorMessage = errorToShow;
      _isLoading = false;
      notifyListeners(); // This makes the error appear on the screen

      // 2. Start a 3-second timer
      Future.delayed(const Duration(seconds: 3), () {
        // 3. After 3 seconds, check if the same error is still showing
        if (_errorMessage == errorToShow) {
          _errorMessage = '';
          notifyListeners(); // This makes the error disappear from the screen
        }
      });

      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // --- SignUp Method ---
  Future<bool> signUp(String email, String password) async {
    // ... (existing signup code)
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await _auth.signOut();
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'An account already exists for that email.';
      } else {
        _errorMessage = 'An error occurred. Please check your details.';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// **[NEW]** Sends a password reset link to the given email.
  /// Returns `true` on success and `false` on failure.
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _isLoading = false;
      notifyListeners();
      return true; // Success

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _errorMessage = 'No user found for that email.';
      } else {
        _errorMessage = 'An error occurred. Please try again.';
      }
      _isLoading = false;
      notifyListeners();
      return false; // Failure
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false; // Failure
    }
  }

  /// Clears the current error message.
  void clearErrorMessage() {
    if (_errorMessage.isNotEmpty) {
      _errorMessage = '';
    }
  }
}

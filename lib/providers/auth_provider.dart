import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:gtg/models/user.dart';
import 'package:gtg/services/auth_service.dart';

/// Authentication state for the GTG app.
/// Uses [AuthService] for Firebase Auth operations.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  // ── State ────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  UserModel? _user;
  String _phoneNumber = '';
  StreamSubscription<fb.User?>? _authSub;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;
  String get phoneNumber => _phoneNumber;

  /// Call once after construction to listen for auth state changes.
  void init() {
    _authSub = _authService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(fb.User? fbUser) async {
    if (fbUser != null) {
      _isAuthenticated = true;
      _user = await _authService.getUserProfile(fbUser.uid);
    } else {
      _isAuthenticated = false;
      _user = null;
    }
    notifyListeners();
  }

  // ── Email/Password ──────────────────────────────────────────────────────

  Future<bool> signInWithEmail(String email, String password) async {
    return _run(() => _authService.signInWithEmail(
          email: email,
          password: password,
        ));
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return _run(() => _authService.signUpWithEmail(
          email: email,
          password: password,
          displayName: displayName,
        ));
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordReset(email);
  }

  // ── Phone OTP ───────────────────────────────────────────────────────────

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submitPhoneNumber() async {
    if (_phoneNumber.trim().isEmpty) {
      _errorMessage = 'Please enter a valid phone number.';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final completer = Completer<bool>();
    await _authService.sendOtp(
      phoneNumber: _phoneNumber,
      onCodeSent: (id) {
        _isLoading = false;
        notifyListeners();
        completer.complete(true);
      },
      onError: (msg) {
        _errorMessage = msg;
        _isLoading = false;
        notifyListeners();
        completer.complete(false);
      },
    );
    return completer.future;
  }

  Future<bool> verifyOtp(String otp) async {
    if (otp.length < 4) {
      _errorMessage = 'Please enter the 4-digit code.';
      notifyListeners();
      return false;
    }
    return _run(() => _authService.verifyOtp(otp));
  }

  Future<void> resendOtp() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _authService.sendOtp(
      phoneNumber: _phoneNumber,
      onCodeSent: (_) {},
      onError: (msg) => _errorMessage = msg,
    );
    _isLoading = false;
    notifyListeners();
  }

  // ── Social ──────────────────────────────────────────────────────────────

  Future<bool> signInWithGoogle() => _run(() => _authService.signInWithGoogle());
  Future<bool> signInWithApple() => _run(() => _authService.signInWithApple());

  // ── Sign Out ────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _authService.signOut();
    _isAuthenticated = false;
    _user = null;
    _phoneNumber = '';
    _errorMessage = null;
    notifyListeners();
  }

  /// Permanently deletes the current user's account & profile data.
  /// Returns false (with [errorMessage] set) on failure, e.g. when
  /// Firebase requires a recent sign-in before allowing deletion.
  Future<bool> deleteAccount() {
    return _run(() async {
      await _authService.deleteAccount();
      _isAuthenticated = false;
      _user = null;
      _phoneNumber = '';
    });
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> _run(Future<dynamic> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _isLoading = false;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _errorMessage = _friendlyMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _friendlyMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password. Try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Password must be at least 8 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'requires-recent-login':
        return 'For your security, please sign in again before deleting your account.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

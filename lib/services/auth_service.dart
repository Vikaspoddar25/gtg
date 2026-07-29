import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gtg/models/user.dart';

class AuthService {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  fb.User? get currentUser => _auth.currentUser;
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  // ── Email/Password ──────────────────────────────────────────────────────

  Future<fb.UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    await _createUserDoc(credential.user!, 'email', displayName: displayName);
    return credential;
  }

  Future<fb.UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  // ── Phone OTP ───────────────────────────────────────────────────────────

  String? _verificationId;

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (fb.PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (fb.FirebaseAuthException e) {
        onError(e.message ?? 'Phone verification failed');
      },
      codeSent: (String id, int? resendToken) {
        _verificationId = id;
        onCodeSent(id);
      },
      codeAutoRetrievalTimeout: (String id) {
        _verificationId = id;
      },
    );
  }

  Future<fb.UserCredential> verifyOtp(String otp) async {
    if (_verificationId == null) {
      throw Exception('No verification ID. Call sendOtp first.');
    }
    final credential = fb.PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    final result = await _auth.signInWithCredential(credential);
    await _createUserDoc(result.user!, 'phone');
    return result;
  }

  // ── Google Sign-In ──────────────────────────────────────────────────────

  Future<fb.UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final googleProvider = fb.GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      final result = await _auth.signInWithPopup(googleProvider);
      await _createUserDoc(result.user!, 'google');
      return result;
    }
    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    await _createUserDoc(result.user!, 'google');
    return result;
  }

  // ── Apple Sign-In ──────────────────────────────────────────────────────

  Future<fb.UserCredential> signInWithApple() async {
    final appleProvider = fb.AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    if (kIsWeb) {
      final result = await _auth.signInWithPopup(appleProvider);
      await _createUserDoc(result.user!, 'apple');
      return result;
    }
    final result = await _auth.signInWithProvider(appleProvider);
    await _createUserDoc(result.user!, 'apple');
    return result;
  }

  // ── Sign Out ────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // ── Delete Account ──────────────────────────────────────────────────────

  /// Deletes the signed-in user's Firestore profile and Firebase Auth
  /// account. Throws [fb.FirebaseAuthException] with code
  /// 'requires-recent-login' if the user must re-authenticate first.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }

  // ── Firestore User Doc ──────────────────────────────────────────────────

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUserProfile(UserModel user) {
    return _firestore.collection('users').doc(user.uid).update(
          user.copyWith(updatedAt: DateTime.now()).toFirestore(),
        );
  }

  Future<void> _createUserDoc(
    fb.User fbUser,
    String provider, {
    String? displayName,
  }) async {
    final docRef = _firestore.collection('users').doc(fbUser.uid);
    final doc = await docRef.get();
    if (doc.exists) return; // Already created

    final now = DateTime.now();
    final user = UserModel(
      uid: fbUser.uid,
      displayName: displayName ?? fbUser.displayName ?? '',
      email: fbUser.email,
      phone: fbUser.phoneNumber,
      photoUrl: fbUser.photoURL,
      authProvider: provider,
      referralCode: _generateReferralCode(),
      createdAt: now,
      updatedAt: now,
    );
    await docRef.set(user.toFirestore());
  }

  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
    );
  }
}

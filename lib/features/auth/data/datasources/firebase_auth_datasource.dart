import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import 'dart:async';

/// FirebaseAuthDataSource - The ONLY place that talks to Firebase SDK.
///
/// WHY ISOLATE FIREBASE CODE HERE:
/// If Firebase ever changes their API, or you migrate to a different
/// auth provider, this is the ONLY file that needs to change.
/// Everything above this layer (repository, use cases, BLoC, UI)
/// remains completely untouched.
class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Sends an OTP to the given phone number.
  /// Returns the verificationId that Firebase generates, which we
  /// need later to confirm the code the user types in.
  Future<String> sendOtp(String phoneNumber) async {
    // A Completer lets us convert Firebase's callback-style API
    // into a modern async/await Future - much easier to work with.
    final completer = _OtpCompleter();

    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,

      // Called if Firebase auto-detects the OTP on Android
      // (reads the SMS automatically - not available on web/iOS)
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification happened - we don't need manual entry
        // We complete with the verificationId if we have one
      },

      // Called if something goes wrong sending the OTP
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e);
      },

      // Called when the OTP has been successfully SENT
      // This gives us the verificationId we need
      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },

      // Called if Firebase times out auto-retrieving the code
      codeAutoRetrievalTimeout: (String verificationId) {
        // No action needed - user will type the code manually
      },

      timeout: const Duration(seconds: 60),
    );

    return completer.future;
  }

  /// Verifies the OTP code and signs the user in.
  Future<UserEntity> verifyOtp({
    required String verificationId,
    required String otpCode,
  }) async {
    // Build a credential object combining the verificationId
    // (proof we sent THIS specific OTP) with the code the user typed
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    // Sign in using this credential - Firebase validates it server-side
    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Sign in succeeded but no user was returned');
    }

    // Check if this user already has a profile in Firestore
    final existingProfile = await _getUserProfile(firebaseUser.uid);
    if (existingProfile != null) {
      return existingProfile;
    }

    // New user - create their profile in Firestore
    final newUser = UserModel(
      uid: firebaseUser.uid,
      phoneNumber: firebaseUser.phoneNumber,
      role: UserRole.user, // Phone signups default to regular user
      createdAt: DateTime.now(),
      isProfileComplete: false,
    );

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(newUser.toFirestore());

    return newUser;
  }

  /// Creates a new account using email and password.
  /// Used for ASHA workers and admins who need role-based access.
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Sign up succeeded but no user was returned');
    }

    final newUser = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      role: role,
      createdAt: DateTime.now(),
      isProfileComplete: false,
    );

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(newUser.toFirestore());

    return newUser;
  }

  /// Signs in an existing user with email and password.
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Sign in succeeded but no user was returned');
    }

    final profile = await _getUserProfile(firebaseUser.uid);
    if (profile == null) {
      throw Exception('User profile not found in database');
    }

    return profile;
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Returns the currently logged-in user, or null if no one is logged in.
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      return await _getUserProfile(firebaseUser.uid)
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      return null;
    }
  }

  /// Private helper - fetches a user's profile document from Firestore.
  Future<UserModel?> _getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 8));
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, uid);
    } catch (_) {
      return null;
    }
  }
}

/// _OtpCompleter - A small helper class wrapping Dart's Completer.
///
/// WHY THIS EXISTS: Firebase's verifyPhoneNumber() uses old-style
/// callbacks (codeSent, verificationFailed, etc.) instead of
/// returning a Future directly. This wrapper converts that callback
/// pattern into a clean Future we can await, matching the rest of
/// our async/await codebase style.
class _OtpCompleter {
  final _completer = Completer<String>();

  void complete(String verificationId) {
    if (!_completer.isCompleted) {
      _completer.complete(verificationId);
    }
  }

  void completeError(Object error) {
    if (!_completer.isCompleted) {
      _completer.completeError(error);
    }
  }

  Future<String> get future => _completer.future;
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  static final Map<String, AppUser> _demoUsers = {};
  static final Map<String, String> _demoPasswords = {};

  User? firebaseUser;
  AppUser? appUser;
  bool isLoading = false;
  String? errorMessage;

  AppAuthProvider() {
    initialize();
  }

  bool get _isFirebaseConfigured => Firebase.apps.isNotEmpty;

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    try {
      if (Firebase.apps.isEmpty) {
        firebaseUser = null;
        appUser = null;
      } else {
        firebaseUser = _authService.currentUser;
        if (firebaseUser != null) {
          appUser = await _firestoreService.fetchUser(firebaseUser!.uid);
        }
      }
    } catch (_) {
      firebaseUser = null;
      appUser = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (!_isFirebaseConfigured) {
        final key = _normalizeEmail(email);
        final savedPassword = _demoPasswords[key];
        final demoUser = _demoUsers[key];

        if (demoUser == null || savedPassword == null) {
          throw Exception('Demo account not found. Create an account first or configure Firebase.');
        }

        if (savedPassword != password.trim()) {
          throw Exception('Invalid password for this demo account.');
        }

        appUser = demoUser;
        firebaseUser = null;
        return;
      }

      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestoreService.fetchUser(credential.user!.uid);
      if (userDoc == null) {
        throw Exception('User profile not found. Please contact admin.');
      }
      if (!userDoc.isActive) {
        await _authService.signOut();
        throw Exception('This account has been deactivated. Please contact the administrator.');
      }

      appUser = userDoc;
      firebaseUser = credential.user;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Login failed.';
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (!_isFirebaseConfigured) {
        final key = _normalizeEmail(email);
        if (_demoUsers.containsKey(key)) {
          throw Exception('This demo account already exists. Please sign in instead.');
        }

        final createdUser = AppUser(
          uid: 'demo_${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          email: email.trim(),
          role: role,
          isActive: true,
          createdAt: DateTime.now(),
        );

        _demoUsers[key] = createdUser;
        _demoPasswords[key] = password.trim();
        appUser = createdUser;
        firebaseUser = null;
        return;
      }

      final cred = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final createdUser = AppUser(
        uid: cred.user!.uid,
        name: name,
        email: email,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestoreService.saveUserProfile(createdUser);
      appUser = createdUser;
      firebaseUser = cred.user;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Registration failed.';
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    firebaseUser = null;
    appUser = null;
    notifyListeners();
  }

  bool get isPatient => appUser?.role == AppConstants.patientRole;
  bool get isDoctor => appUser?.role == AppConstants.doctorRole;
  bool get isAdmin => appUser?.role == AppConstants.adminRole;
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:she_secure/models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User stream - use FirebaseAuth directly for more reliability
  Stream<User?> get user => _auth.authStateChanges();

  // Sign Up
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    String phone = '',
  }) async {
    User? firebaseUser;
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      firebaseUser = credential.user;

      // Create user document
      UserModel newUser = UserModel(
        uid: firebaseUser!.uid,
        email: email,
        fullName: fullName,
        role: 'user',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toMap());

      // Log registration
      await _logActivity(
        firebaseUser.uid,
        'registration',
        'User registered successfully',
      );

      return newUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      // If Firestore fails, we should delete the auth user to maintain consistency
      if (firebaseUser != null) {
        await firebaseUser.delete();
      }
      debugPrint('Firestore Error during signUp: $e');
      throw 'Database Error: Please check your internet or Firestore rules.';
    }
  }

  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // If Auth succeeds but no Firestore doc, we sign out
        await _auth.signOut();
        throw 'User profile not found in database.';
      }

      UserModel user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

      // Log login
      await _logActivity(
        credential.user!.uid,
        'login',
        'User logged in successfully',
      );

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      debugPrint('Error during signIn: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      String? userId = _auth.currentUser?.uid;

      // First, log the logout activity
      if (userId != null) {
        try {
          await _logActivity(userId, 'logout', 'User logged out');
        } catch (e) {
          debugPrint('Failed to log logout activity: $e');
        }
      }

      // Then sign out from Firebase
      await _auth.signOut();

      // Wait a bit to ensure auth state is updated
      await Future.delayed(const Duration(milliseconds: 100));

      debugPrint('Sign out successful');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during signOut: $e');
      throw 'Logout failed: ${e.message}';
    } catch (e) {
      debugPrint('Error during signOut: $e');
      throw 'Logout failed: Please try again';
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      rethrow;
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;

    try {
      // 1. Delete from Firestore
      await _firestore.collection('users').doc(uid).delete();
      
      // 2. Delete activity logs (optional, but good for privacy)
      final logs = await _firestore.collection('activity_logs')
          .where('userId', isEqualTo: uid).get();
      for (var doc in logs.docs) {
        await doc.reference.delete();
      }

      // 3. Delete Auth User
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw 'Account deletion requires a recent login. Please log in again and try again.';
      }
      throw _handleAuthError(e);
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  // Get Current User
  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  // Activity Logging
  Future<void> _logActivity(
      String userId,
      String event,
      String description,
      ) async {
    try {
      await _firestore.collection('activity_logs').add({
        'userId': userId,
        'event': event,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'mobile',
      });
    } catch (e) {
      debugPrint('Failed to log activity: $e');
    }
  }

  // Error Handler
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-not-found':
        return 'No account found with this email';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}

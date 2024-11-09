import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:smartkidstracker/src/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      debugPrint('Firebase Initialized');
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
    }
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String firstName,
    required String middleName,
    required String lastName,
    required String phoneNumber,
    String? school,
    String? section,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'firstName': firstName,
          'middleName': middleName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'school': school ?? '',
          'section': section ?? '',
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign-up failed: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> signInWithEmailAndPassword(String email, String password) async {
  try {
    debugPrint('Attempting to sign in with email: $email');
    final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = userCredential.user;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final String role = userData['role']?.toLowerCase() ?? '';

        if (role == 'admin') {
          // Admins can sign in without confirmation checks.
          return _buildUserResponse(userData, role);
        } else if (role == 'teacher') {
          // Check confirmed_teachers for teachers.
          return await _handleRoleConfirmation(user.uid, userData, 'teacher');
        } else if (role == 'parent' || role == 'guardian') {
          // Check confirmed_children for parents/guardians.
          return await _handleRoleConfirmation(user.uid, userData, 'child');
        } else {
          await _firebaseAuth.signOut();
          return _buildErrorResponse('Invalid user role');
        }
      } else {
        await _firebaseAuth.signOut();
        return _buildErrorResponse('User data not found');
      }
    } else {
      return _buildErrorResponse('User not found');
    }
  } catch (e) {
    debugPrint('Error during sign in: $e');
    return _buildErrorResponse('Sign-in error: $e');
  }
}

Future<Map<String, dynamic>> _handleRoleConfirmation(String uid, Map<String, dynamic> userData, String roleType) async {
  // Check confirmed collection based on the role type (teacher or child).
  final String confirmationCollection = 'confirmed_${roleType}s';
  DocumentSnapshot confirmedDoc = await _firestore.collection(confirmationCollection).doc(uid).get();

  if (confirmedDoc.exists) {
    return _buildUserResponse(userData, roleType);
  } else {
    await _firebaseAuth.signOut();
    return _buildErrorResponse('User is not confirmed in $confirmationCollection');
  }
}


  Map<String, dynamic> _buildUserResponse(Map<String, dynamic> userData, String role) {
    return {
      'success': true,
      'firstName': userData['firstName'] ?? '',
      'lastName': userData['lastName'] ?? '',
      'section': userData['section'] ?? '',
      'role': role,
    };
  }

  Map<String, dynamic> _buildErrorResponse(String error) {
    return {'success': false, 'error': error};
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final String role = userData['role'] ?? '';

          if (['admin', 'teacher', 'child'].contains(role.toLowerCase())) {
            await _navigateToMainScreen(context, userData, role);
          } else {
            _showSnackBar(context, 'Invalid user role');
            await _firebaseAuth.signOut();
          }
        } else {
          _showSnackBar(context, 'User data not found');
          await _firebaseAuth.signOut();
        }
      }
    } catch (e) {
      _showSnackBar(context, 'Error during Google Sign-In: $e');
    }
  }

  Future<void> _navigateToMainScreen(BuildContext context, Map<String, dynamic> userData, String role) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          section: userData['section'] ?? '',
          role: role,
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint('User signed out');
    } catch (e) {
      debugPrint('Error signing out: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> updateUserChildren(String userId, List<Map<String, String>> children) async {
    try {
      // Reference to the user's document in Firestore
      DocumentReference userDoc = _firestore.collection('users').doc(userId);

      // Update the children field with the provided list
      await userDoc.update({
        'children': children,
      });

      print('Children data updated for userId: $userId');
    } catch (e) {
      print('Error in updateUserChildren: $e');
      throw Exception('Failed to update children data: $e');
    }
  }
}

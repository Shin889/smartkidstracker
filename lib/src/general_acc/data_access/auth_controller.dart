import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartkidstracker/src/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  get phoneNumber => null;
  get email => null;

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
    String? section,
    required String role,
    required String selectedRole,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
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
          'section': section ?? '',
          'role': role,
          'status': "Pending",
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

  Future<Map<String, dynamic>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      debugPrint('Attempting to sign in with email: $email');
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final String role = userData['role']?.toLowerCase() ?? '';
          print(role);

          if (role == 'teacher') {
            return _buildUserResponse(userData, role);
          } else if (role == 'parent' ||
              role == 'parent') {
            // Check confirmed_children for parents/guardians.
            if (userData["status"] == "Confirmed") {
              return _buildUserResponse(userData, role);
            } else {
              return _buildErrorResponse(
                  'Parent is still not confirmed');
            }
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

  Future<Map<String, dynamic>> _handleRoleConfirmation(
      String uid, Map<String, dynamic> userData, String roleType) async {
    // Check confirmed collection based on the role type (teacher or child).
    final String confirmationCollection = 'confirmed_${roleType}s';
    DocumentSnapshot confirmedDoc =
        await _firestore.collection(confirmationCollection).doc(uid).get();

    if (confirmedDoc.exists) {
      return _buildUserResponse(userData, roleType);
    } else {
      await _firebaseAuth.signOut();
      return _buildErrorResponse(
          'User is not confirmed in $confirmationCollection');
    }
  }

  Future<Map<String, dynamic>> _handleRoleConfirmation2(
      String uid, Map<String, dynamic> userData, String roleType) async {
    // Check confirmed collection based on the role type (teacher or child).
    final String confirmationCollection = 'confirmed_$roleType';
    QuerySnapshot querySnapshot = await _firestore
        .collection(confirmationCollection)
        .where('userUid', isEqualTo: uid)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot confirmedDoc = querySnapshot.docs.first;
      return _buildUserResponse(userData, roleType);
    } else {
      await _firebaseAuth.signOut();
      return _buildErrorResponse(
          'User is not confirmed in $confirmationCollection');
    }
  }

  Map<String, dynamic> _buildUserResponse(
      Map<String, dynamic> userData, String role) {
    return {
      'success': true,
      'firstName': userData['firstName'] ?? '',
      'lastName': userData['lastName'] ?? '',
      'section': userData['section'] ?? '',
      'role': role,
      'email': userData['email'] ?? '',
    };
  }

  Map<String, dynamic> _buildErrorResponse(String error) {
    return {'success': false, 'error': error};
  }

  Future<void> _navigateToMainScreen(
      BuildContext context, Map<String, dynamic> userData, String role) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          section: userData['section'] ?? '',
          email: userData['email'] ?? '',
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

  Future<void> updateUserChildren(String userId, String email,
      String phoneNumber, List<Map<String, String>> children) async {
    try {
      // Reference to the `pending_children` collection
      CollectionReference pendingChildren = _firestore.collection('children');

      for (var child in children) {
        await pendingChildren.add({
          'email': email,
          'phoneNumber': phoneNumber,
          'parentId': userId,
          'childName': child['name'],
          'childSection': child['section'],
          'status': "Pending",
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      debugPrint('Children data moved to pending_children for userId: $userId');
    } catch (e) {
      debugPrint('Error in updateUserChildren: $e');
      throw Exception('Failed to update children data: $e');
    }
  }

  Future<UserCredential> signUpWithEmailPassword(
      String email, String password) async {
    try {
      // Create a new user with the provided email and password
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Return the user credential on successful sign up
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle different error codes and throw more meaningful messages
      if (e.code == 'email-already-in-use') {
        throw Exception(
            'The email address is already in use by another account.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else {
        throw Exception('Failed to sign up: ${e.message}');
      }
    } catch (e) {
      // Handle any other exceptions
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

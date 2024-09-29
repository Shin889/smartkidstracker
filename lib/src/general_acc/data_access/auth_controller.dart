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
      print('Firebase Initialized');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  Future<bool> checkSchoolExists(String schoolName) async {
    try {
      QuerySnapshot schoolQuery = await _firestore
          .collection('schools')
          .where('name', isEqualTo: schoolName)
          .limit(1)
          .get();
      return schoolQuery.docs.isNotEmpty;
    } catch (e) {
      print('Error checking school existence: $e');
      return false;
    }
  }

Future<List<Map<String, dynamic>>> getPendingChildrenForSchool(String schoolName) async {
  try {
    QuerySnapshot childrenQuery = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'child')
        .where('school', isEqualTo: schoolName)
        .where('status', isEqualTo: 'pending')
        .get();

    return childrenQuery.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  } catch (e) {
    print('Error getting pending children: $e');
    rethrow;
  }
}

  Future<void> updateChildren(String userId, List<Map<String, dynamic>> pendingChildren) async {
    try {
      // Convert each child map to Map<String, String>
      List<Map<String, String>> children = pendingChildren.map((child) {
        return child.map((key, value) => MapEntry(key, value.toString())).cast<String, String>();
      }).toList();

      // Update Firestore with the converted List<Map>
      await _firestore.collection('users').doc(userId).update({
        'children': children,
      });
      print('User children updated successfully.');
    } catch (e) {
      print('Error updating user children: $e');
      throw Exception('Failed to update user children: $e');
    }
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String firstName,
    required String middleName,
    required String lastName,
    required String phoneNumber,
    required String school,
    required String section,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'school': school,
        'section': section,
        'role': role,
        'status': 'pending',
      });
      return userCredential;
    } catch (e) {
      print('Error during sign up: $e');
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<void> updateUserChildren(String userId, List<Map<String, dynamic>> children) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'children': children,
      });
    } catch (e) {
      print('Error updating user children: $e');
      throw Exception('Failed to update user children: $e');
    }
  }

  Future<void> updateChildStatus(String childId, String status) async {
    try {
      await _firestore.collection('children').doc(childId).update({
        'status': status,
      });
      print('Child status updated to $status');
    } catch (e) {
      print('Error updating child status: $e');
      throw Exception('Failed to update child status: $e');
    }
  }

  Future<UserCredential> signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('User signed in: ${userCredential.user!.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign-in: ${e.code} - ${e.message}');
      throw Exception('Failed to sign in: ${e.message}');
    } catch (e) {
      print('Unexpected error during sign-in: $e');
      throw Exception('An unexpected error occurred during sign-in: $e');
    }
  }

  Future<void> verifyCode(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _firebaseAuth.signInWithCredential(credential);
      print('Phone number verified');
    } catch (e) {
      print('Error verifying code: $e');
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
	  if (googleUser == null) return; // User canceled the sign-in
      
	  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

	  final AuthCredential credential = GoogleAuthProvider.credential(
		accessToken: googleAuth.accessToken,
		idToken: googleAuth.idToken,
	  );

	  final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
	  final User? user = userCredential.user;

	  if (user != null) {
		Navigator.pushReplacement(
		  context,
		  MaterialPageRoute(
			builder: (context) => MainScreen(
			  firstName: user.displayName?.split(' ').first ?? '',
			  lastName: user.displayName?.split(' ').last ?? '',
			  section: '',
			  role: '',
			),
		  ),
		);
	  }
	} catch (e) {
	  ScaffoldMessenger.of(context).showSnackBar(
		SnackBar(content: Text('Error during Google Sign-In: $e')),
	  );
	}
  }

  Future<List<Map<String, dynamic>>> getPendingChildren() async {
    try {
      QuerySnapshot childrenQuery = await _firestore
          .collection('children')
          .where('status', isEqualTo: 'pending')
          .get();
      
	  return childrenQuery.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
	  }).toList();
      
	} catch (e) {
	  print('Error getting pending children from Firestore: $e');
	  return [];
	}
  }

  Future<Map<String, dynamic>> signInWithEmailAndPassword(String email, String password) async {
    try {
       final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
         email: email,
         password: password,
       );

       final User? user = userCredential.user;

       if (user != null) {

         // Retrieve user data from Firestore or any other source if necessary
         DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

         final userData = userDoc.data() as Map<String, dynamic>;

         return {
           'success': true,
           'firstName': userData['firstName'] ?? '',
           'lastName': userData['lastName'] ?? '',
           'section': userData['section'] ?? '',
           'role': userData['role'] ?? '',
         };
       } else {

         return {'success': false};
       }
     } catch (e) {

       return {'success': false, 'error': e.toString()};
     }
   }

   Future<void> signOut() async {
     try {
       await _firebaseAuth.signOut();
       print('User signed out');
     } catch (e) {
       print('Error signing out: $e');
       throw Exception('Failed to sign out: $e');
     }
   }

   User? getCurrentUser() {
     return _firebaseAuth.currentUser;
   }

   // Methods related to OTP
   Future<void> sendOTP(String contactInfo) async {
     await _firebaseAuth.verifyPhoneNumber(
       phoneNumber: contactInfo,
       verificationCompleted: (PhoneAuthCredential credential) async {
         await _firebaseAuth.signInWithCredential(credential);
       },
       verificationFailed: (FirebaseAuthException e) {
         throw Exception('Verification failed: ${e.message}');
       },
       codeSent: (String verificationId, int? resendToken) {},
       codeAutoRetrievalTimeout: (String verificationId) {},
     );
   }

   Future<bool> verifyOTP(String verificationId, String smsCode) async {
     try {
       PhoneAuthCredential credential = PhoneAuthProvider.credential(
         verificationId: verificationId,
         smsCode: smsCode,
       );
       await _firebaseAuth.signInWithCredential(credential);
       return true;
     } catch (e) {
       return false;
     }
   }
}
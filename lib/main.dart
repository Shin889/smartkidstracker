import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartkidstracker/src/main_screen.dart';
import 'package:smartkidstracker/src/menu_drawer/announcement/announcement.dart';
import 'package:smartkidstracker/src/minor_deets/about_screen.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/presentation/record.dart';
import 'package:smartkidstracker/src/menu_drawer/account_authentication/teacher_acc.dart';
import 'package:smartkidstracker/src/menu_drawer/teacher_record/presentation/record.dart';
import 'package:smartkidstracker/src/menu_drawer/student_record/presentation/record.dart';
import 'package:smartkidstracker/src/menu_drawer/account_authentication/pg_acc.dart';
import 'package:smartkidstracker/src/general_acc/presentation/signin_screen.dart';
import 'dart:async';  // Import for runZonedGuarded // Import the NativeMethods class

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runZonedGuarded(() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    runApp(const MyApp());
  }, (error, stackTrace) {
    print('Caught error: $error');
    print('Stack trace: $stackTrace');
    // Add error logging here if needed
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smartkids Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/signin',
      routes: {
        '/': (context) => const MainScreen(
              firstName: '', 
              lastName: '',
              section: '',
              role: '',
            ),
        '/announcement': (context) => const Announcement(selectedRole: ''),  
        '/attendance': (context) => const AttendanceScreen(),
        '/about': (context) => const AboutScreen(),
        '/teacher_auth': (context) => const TeacherAcc(),
        '/teacher_record': (context) => const TeacherRecordScreen(),
        '/student_record': (context) => const StudentRecords(),
        '/pg_auth': (context) => PgAccScreen(
              childName: '',
              userRole: '',
              schoolName: '',
              section: '',
            ),
        '/signin': (context) => const SignInScreen(), 
      },
    );
  }
}

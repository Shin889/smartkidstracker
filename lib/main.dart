import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartkidstracker/src/menu_drawer/add_child/add_child.dart';
import 'firebase_options.dart';
import 'package:smartkidstracker/src/main_screen.dart';
import 'package:smartkidstracker/src/menu_drawer/announcement/announcement.dart';
import 'package:smartkidstracker/src/minor_deets/about_screen.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/presentation/record.dart';
import 'package:smartkidstracker/src/menu_drawer/student_record/presentation/record.dart';
import 'package:smartkidstracker/src/menu_drawer/account_authentication/pg_acc.dart';
import 'package:smartkidstracker/src/general_acc/views/signin_screen.dart';
import 'package:smartkidstracker/src/general_acc/views/signup_screen.dart';
import 'package:smartkidstracker/src/minor_deets/privacy_policy.dart';
import 'package:smartkidstracker/src/minor_deets/user_agreement.dart';
import 'dart:async';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Set up background messaging handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  void _initializeFirebaseMessaging() async {
    _firebaseMessaging = FirebaseMessaging.instance;

    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();
    print('User granted permission: ${settings.authorizationStatus}');

    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Smartkids Tracker',
        scrollBehavior: MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.stylus, PointerDeviceKind.unknown},
        ),
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/signin',
        routes: {
          '/': (context) => MainScreen(
              firstName: '', lastName: '', section: '', role: '', email: ''),
          '/announcement': (context) => const Announcement(selectedRole: ''),
          '/attendance': (context) => AttendanceScreen(
                userDocId: '',
              ),
          '/about': (context) => const AboutScreen(),
          '/student_record': (context) => StudentRecords(),
          '/pg_auth': (context) => PgAccScreen(
              firstName: '',
              middleName: '',
              lastName: '',
              userRole: '',
              childSection: '',
              email: '',
              phone: ''),
          '/signin': (context) => const SignInScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/privacy_policy': (context) => const PrivacyPolicy(),
          '/user_agreement': (context) => const UserAgreement(),
          '/add_child': (context) => AddChildScreen(email: '', phoneNumber: ''),
          '/main': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map?;
            return MainScreen(
              firstName: args?['firstName']?.toString() ?? '',
              lastName: args?['lastName']?.toString() ?? '',
              section: args?['section']?.toString() ?? '',
              role: args?['role']?.toString() ?? '',
              email: args?['email']?.toString() ?? '',
            );
          },
        });
  }
}

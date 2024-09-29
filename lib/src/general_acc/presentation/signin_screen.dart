import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smartkidstracker/src/minor_deets/privacy_policy.dart';
import 'package:smartkidstracker/src/minor_deets/user_agreement.dart';
import 'package:smartkidstracker/src/general_acc/presentation/signup_screen.dart';
import 'package:smartkidstracker/src/general_acc/data_access/auth_controller.dart';
import 'package:smartkidstracker/src/main_screen.dart';
import 'package:smartkidstracker/src/widgets/button.dart';

const firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyAoxbr2DTijagxq5Dnjb3vm6UCgP3TxTuM",
  appId: "1:224966435149:android:f9008b6f07107025fbd704",
  messagingSenderId: "224966435149",
  projectId: "smartkidstracker-35ac5",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: firebaseOptions,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartKidsTracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
      '/': (context) => const SignInScreen(),
      '/signup': (context) => const SignUpScreen(),
      '/user_agreement': (context) => const UserAgreementPage(),
      '/privacy_policy': (context) => const PrivacyPolicyPage(),
      '/main': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?; // Change here
        return MainScreen(
          firstName: args?['firstName']?.toString() ?? '',
          lastName: args?['lastName']?.toString() ?? '',
          section: args?['section']?.toString() ?? '',
          role: args?['role']?.toString() ?? '',
        );
      },
    },

    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map result = await _authController.signInWithEmailAndPassword(
          _emailOrPhoneController.text,
          _passwordController.text,
        );
        if (result['success'] == true) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(
            context,
            '/main',
            arguments: {
              'firstName': result['firstName'] ?? '',
              'lastName': result['lastName'] ?? '',
              'section': result['section'] ?? '',
              'role': result['role'] ?? '',
            },
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to sign in')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double baseFontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              Text(
                'Smartkids Tracker',
                style: TextStyle(
                  fontFamily: 'GreatVibes',
                  color: Colors.black,
                  fontSize: baseFontSize * 1.8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailOrPhoneController,
                      decoration: InputDecoration(
                        hintText: 'Email/phone number',
                        hintStyle: TextStyle(fontSize: screenWidth * 0.035),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email or phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(fontSize: screenWidth * 0.035),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                onPressed: _handleSignIn,
                text: 'Sign In',
                fontSize: screenWidth * 0.04,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New user? ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    child: Text(
                      'Create account >',
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Or log in with',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => _authController.handleGoogleSignIn(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Icon(
                    Icons.g_mobiledata,
                    size: screenWidth * 0.06,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 2,
                  runSpacing: 0,
                  children: [
                    Text(
                      'By logging in, you agree to our ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'User Agreement',
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/user_agreement');
                      },
                    ),
                    Text(
                      ' & ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/privacy_policy');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
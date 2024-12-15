import 'package:flutter/material.dart';
import 'package:smartkidstracker/src/general_acc/data_access/auth_controller.dart';
import 'package:smartkidstracker/src/widgets/button.dart';

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
  bool _isPasswordVisible = false; // For password visibility
  bool _keepSignedIn = false; // For keeping user signed in

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
              'email': result['email'] ?? '',
            },
          );
        } else {
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
    double checkboxSize = screenWidth * 0.05; // Checkbox size for scaling

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              const SizedBox(height: 40), // Added space at the top
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
                      obscureText: !_isPasswordVisible, // Toggle visibility
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(fontSize: screenWidth * 0.035),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton( // Show password icon
                          icon:
                              Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Transform.scale( // Scale down the checkbox
                          scale: checkboxSize / 24, // Adjust scale factor as needed
                          child: Checkbox(
                            value: _keepSignedIn,
                            onChanged: (bool? value) {
                              setState(() {
                                _keepSignedIn = value!;
                              });
                            },
                          ),
                        ),
                        Expanded( // Use Expanded for responsive layout
                          child: Text(
                            'Keep me signed in',
                            style:
                                TextStyle(fontSize: baseFontSize * 0.9), // Scale text size down
                            overflow: TextOverflow.ellipsis, // Handles long text gracefully
                          ),
                        ),
                      ],
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
                    style:
                        TextStyle(color: Colors.black, fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    child:
                        Text('Create account >', style:
                            TextStyle(color: Colors.purple, fontSize:
                                screenWidth * 0.035)),
                    onPressed:
                        () { Navigator.pushNamed(context, '/signup'); },
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  'By logging in, you agree to our ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/user_agreement');
                  },
                  child: Text(
                    'User Agreement',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Text(
                  ' & ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/privacy_policy');
                  },
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
           ], 
          ), 
        ), 
      )
    ); 
  } 
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartkidstracker/src/general_acc/data_access/auth_controller.dart';
import 'package:smartkidstracker/src/general_acc/views/signin_screen.dart';
import 'package:smartkidstracker/src/general_acc/data_access/role_auth/parent_signup.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  String _firstName = '';
  String _middleName = '';
  String _lastName = '';
  String _phoneNumber = '';
  String _email = '';
  String _password = '';
  String _selectedRole = '';
  String _section = '';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildRoleSelection(),
                _buildCommonFields(screenWidth),
                const SizedBox(height: 24.0),
                _buildSignUpButton(screenWidth),
                const SizedBox(height: 12.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Role:'),
        _buildRadioTile('Parent'),
        _buildRadioTile('Teacher'),
      ],
    );
  }

  RadioListTile<String> _buildRadioTile(String role) {
    return RadioListTile(
      title: Text(role),
      value: role,
      groupValue: _selectedRole,
      onChanged: (String? value) {
        setState(() {
          _selectedRole = value!;
          if (_selectedRole == 'Parent') {
            _section = '';
          }
        });
      },
    );
  }

  Widget _buildCommonFields(double screenWidth) {
    return Column(
      children: [
        _buildTextFormField('First Name', screenWidth, (value) {
          if (value == null || value.isEmpty) return 'Please enter your first name';
          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) return 'First name can only contain letters';
          return null;
        }, (value) => _firstName = value!),
        const SizedBox(height: 12.0),
        _buildTextFormField('Middle Name', screenWidth, null, (value) => _middleName = value ?? ''),
        const SizedBox(height: 12.0),
        _buildTextFormField('Last Name', screenWidth, (value) {
          if (value == null || value.isEmpty) return 'Please enter your last name';
          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) return 'Last name can only contain letters';
          return null;
        }, (value) => _lastName = value!),
        const SizedBox(height: 12.0),
        _buildPhoneNumberField(screenWidth),
        const SizedBox(height: 12.0),
        _buildTextFormField('Email', screenWidth, (value) {
          if (value == null || value.isEmpty) return 'Please enter your email';
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        }, (value) => _email = value!),
        const SizedBox(height: 12.0),
        _buildPasswordField(screenWidth),
        if (_selectedRole == 'Teacher') ...[
          const SizedBox(height: 12.0),
          _buildTextFormField('Section', screenWidth, (value) {
            if (value == null || value.isEmpty) return 'Please enter the section name';
            return null;
          }, (value) => _section = value!),
        ],
      ],
    );
  }

  TextFormField _buildTextFormField(String label, double screenWidth, String? Function(String?)? validator, Function(String?)? onSaved) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: screenWidth * 0.035),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  TextFormField _buildPhoneNumberField(double screenWidth) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Phone Number',
        labelStyle: TextStyle(fontSize: screenWidth * 0.035),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your phone number';
        if (value.length != 11) return 'Phone number must be exactly 11 digits';
        return null;
      },
      onSaved: (value) => _phoneNumber = value!,
    );
  }

  TextFormField _buildPasswordField(double screenWidth) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(fontSize: screenWidth * 0.035),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter a password';
        if (value.length < 8) return 'Password must be at least 8 characters long';
        return null;
      },
      onSaved: (value) => _password = value!,
    );
  }

  Widget _buildSignUpButton(double screenWidth) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          _handleSignUp();
        }
      },
      child: Text('Sign Up', style: TextStyle(fontSize: screenWidth * 0.04)),
    );
  }

  Future<void> _handleSignUp() async {
    try {

      UserCredential userCredential = await _authController.signUp(
        email: _email,
        password: _password,
        firstName: _firstName,
        middleName: _middleName,
        lastName: _lastName,
        phoneNumber: _phoneNumber,
        section: _section,
        role: _selectedRole,
        selectedRole: '', children: [],
      );

      if (userCredential.user != null) {
        if (mounted) {
          if (_selectedRole == 'Teacher') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
          } else if (_selectedRole == 'Parent') {
            Navigator.push(context, MaterialPageRoute(builder:(context)=> ParentSignUpScreen(email:_email, phoneNumber:_phoneNumber)));
          }
        }
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
         Text('Error:$e')));
       }
     }
   }

   Future<void>_saveTeacherData(String userId)
   async{
     try{
       await FirebaseFirestore.instance.collection('teachers').doc(userId).set({
         'firstName':_firstName,
         'middleName':_middleName,
         'lastName':_lastName,
         'section':_section,
       });
       Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>const SignInScreen()));
     }catch(e){
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
       Text('Failed to save data:$e')));
     }
   }
}

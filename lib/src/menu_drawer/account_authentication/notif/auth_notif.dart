import 'package:flutter/material.dart';
import 'package:smartkidstracker/src/general_acc/data_access/auth_controller.dart';
import 'package:smartkidstracker/src/general_acc/presentation/signin_screen.dart';

class AccountVerificationScreen extends StatefulWidget {
  final String userId;
  final String role;
  final String contactInfo;

  const AccountVerificationScreen({
    super.key,
    required this.userId,
    required this.role,
    required this.contactInfo,
  });

  @override
  _AccountVerificationScreenState createState() => _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();
  String _otp = '';
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _sendVerification();
  }

  Future<void> _sendVerification() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      if (widget.role == 'Admin') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin account is pending verification by a super admin.')),
        );
      } else {
        await _authController.sendOTP(widget.contactInfo); // Assume contactInfo is email or phone
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification code sent to ${widget.contactInfo}.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending verification: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Verification'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Verifying ${widget.role} Account',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24.0),
                if (widget.role != 'Admin') _buildOTPField(),
                const SizedBox(height: 24.0),
                if (widget.role != 'Admin') _buildVerifyButton(),
                if (widget.role == 'Admin') _buildAdminMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Enter Verification Code'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter the verification code';
        }
        return null;
      },
      onSaved: (value) => _otp = value ?? '',
    );
  }

  Widget _buildVerifyButton() {
    return ElevatedButton(
      onPressed: _isVerifying ? null : _verifyOTP,
      child: _isVerifying
          ? const SizedBox(
              height: 20.0,
              width: 20.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.white,
              ),
            )
          : const Text('Verify'),
    );
  }

  Widget _buildAdminMessage() {
    return const Text(
      'Your admin account is pending verification. Please wait for approval from a super admin.',
      textAlign: TextAlign.center,
    );
  }

  Future<void> _verifyOTP() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isVerifying = true;
      });

      try {
        bool isVerified = await _authController.verifyOTP(widget.userId, _otp);
        if (isVerified) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const SignInScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid verification code. Please try again.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }
}

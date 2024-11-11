import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartkidstracker/src/general_acc/data_access/auth_controller.dart';

class ParentSignUpScreen extends StatefulWidget {
  final String email;
  final String phoneNumber;

  const ParentSignUpScreen({
    super.key,
    required this.email,
    required this.phoneNumber,
  });

  @override
  _ParentSignUpScreenState createState() => _ParentSignUpScreenState();
}

class _ParentSignUpScreenState extends State<ParentSignUpScreen> {
  final List<Map<String, String>> _children = [{'name': '', 'school': '', 'section': ''}];
  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Child Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(child: _buildChildrenList()),
              ElevatedButton(
                onPressed: _addAnotherChild,
                child: const Text('Add Another Child'),
              ),
              const SizedBox(height: 16.0),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitSignUpRequest,
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChildrenList() {
    return ListView.builder(
      itemCount: _children.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Child Name'),
              validator: (value) => value == null || value.isEmpty ? "Please enter the child's name" : null,
              onSaved: (value) => _children[index]['name'] = value ?? '',
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Child School'),
              validator: (value) => value == null || value.isEmpty ? "Please enter the child's school" : null,
              onSaved: (value) => _children[index]['school'] = value ?? '',
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Child Section'),
              validator: (value) => value == null || value.isEmpty ? "Please enter the child's section" : null,
              onSaved: (value) => _children[index]['section'] = value ?? '',
            ),
            const SizedBox(height: 16.0),
          ],
        );
      },
    );
  }

  void _addAnotherChild() {
    setState(() {
      _children.add({'name': '', 'school': '', 'section': ''});
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New child section added')),
    );
  }

  Future<void> _submitSignUpRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      _formKey.currentState!.save();

      try {
        await savePendingChildData(
          email: widget.email,
          phoneNumber: widget.phoneNumber,
          children: _children,
        );

        setState(() {
          _isSubmitting = false;
        });

        Navigator.of(context).pushReplacementNamed('/signin');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Children added successfully. Your request is pending approval.'),
            ),
          );
        });
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> savePendingChildData({
  required String email,
  required String phoneNumber,
  required List<Map<String, String>> children,
}) async {
  // Get the user ID of the current authenticated user
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    throw Exception('User not authenticated');
  }

  String userId = currentUser.uid;

  // Call the `updateUserChildren` method with all required arguments
  await _authController.updateUserChildren(
    userId,
    email,
    phoneNumber,
    children,
    );
  }
}

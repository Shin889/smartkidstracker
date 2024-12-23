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
  final List<Map<String, String>> _children = [{'name': '', 'section': ''}];
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
      appBar: AppBar(
        title: const Text('Child Sign Up'),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: _buildChildrenList(),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: _addAnotherChild,
                icon: const Icon(Icons.add),
                label: const Text('Add Another Child'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submitSignUpRequest,
                      icon: const Icon(Icons.check),
                      label: const Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
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
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Child ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (value) => value == null || value.isEmpty ? "Please enter the child's first name" : null,
                  onSaved: (value) => _children[index]['firstName'] = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Middle Name'),
                  validator: (value) => value == null || value.isEmpty ? "Please enter the child's middle name" : null,
                  onSaved: (value) => _children[index]['middleName'] = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (value) => value == null || value.isEmpty ? "Please enter the child's last name" : null,
                  onSaved: (value) => _children[index]['lastName'] = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Child Section'),
                  validator: (value) => value == null || value.isEmpty ? "Please enter the child's section" : null,
                  onSaved: (value) => _children[index]['section'] = value ?? '',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addAnotherChild() {
    setState(() {
      _children.add({'firstName': '', 'middleName': '', 'lastName': '', 'section': ''});
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
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    String userId = currentUser.uid;
    await _authController.updateUserChildren(
      userId,
      email,
      phoneNumber,
      children,
    );
  }
}

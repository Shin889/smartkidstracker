import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartkidstracker/src/general_acc/data_access/auth_controller.dart';

class ParentSignUpScreen extends StatefulWidget {
  final String userId;

  const ParentSignUpScreen({super.key, required this.userId});

  @override
  _ParentSignUpScreenState createState() => _ParentSignUpScreenState();
}

class _ParentSignUpScreenState extends State<ParentSignUpScreen> {
  final List<Map<String, String>> _children = [{'name': '', 'school': '', 'section': ''}];
  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != widget.userId) {
      Navigator.of(context).pushReplacementNamed('/login');
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
              ElevatedButton(onPressed: _addAnotherChild, child: const Text('Add Another Child')),
              const SizedBox(height: 16.0),
              ElevatedButton(onPressed: _submitSignUpRequest, child: const Text('Submit')),
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
        return Column(children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Child Name'),
            validator: (value) => value == null || value.isEmpty ? "Please enter the child's name" : null,
            onSaved: (value) => _children[index]['name'] = value ?? '', // Ensure value is not null
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Child School'),
            validator: (value) => value == null || value.isEmpty ? "Please enter the child's school" : null,
            onSaved: (value) => _children[index]['school'] = value ?? '', // Ensure value is not null
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Child Section'),
            validator: (value) => value == null || value.isEmpty ? "Please enter the child's section" : null,
            onSaved: (value) => _children[index]['school'] = value ?? '',
          ), // Ensure value is not null
          const SizedBox(height: 16.0),
        ]);
      },
    );
  }

  void _addAnotherChild() {
    setState(() { 
      _children.add({'name': '', 'school': '', 'section': ''}); // Ensure new child entry is valid
    });
  }

 void _submitSignUpRequest() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    try {
      print('Children data before update: $_children');
      print('User ID: ${widget.userId}');
      await _authController.updateUserChildren(widget.userId, _children);
      print('Children data updated successfully');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Children information updated successfully.')));
    } catch (e) {
      print('Error in _submitSignUpRequest: $e');
      print('Stack trace: ${StackTrace.current}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error : $e')));
    }
  }
 }
}
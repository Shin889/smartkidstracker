import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartkidstracker/src/general_acc/data_access/auth_controller.dart';

class AddChildScreen extends StatefulWidget {
  final String email;
  final String phoneNumber;

  const AddChildScreen({
    super.key,
    required this.email,
    required this.phoneNumber,
  });

  @override
  _AddChildScreenState createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final List<TextEditingController> _firstNameControllers = [];
  final List<TextEditingController> _middleNameControllers = [];
  final List<TextEditingController> _lastNameControllers = [];
  final List<TextEditingController> _sectionControllers = [];
  final List<Map<String, String>> _children = [
    {'firstName': '', 'middleName': '', 'lastName': '', 'section': ''}
  ];
  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addControllers();
  }

  void _addControllers() {
    _firstNameControllers.add(TextEditingController());
    _middleNameControllers.add(TextEditingController());
    _lastNameControllers.add(TextEditingController());
    _sectionControllers.add(TextEditingController());
  }

  void _clearForm() {
    setState(() {
      // Clear all controllers
      for (var controller in _firstNameControllers) {
        controller.clear();
      }
      for (var controller in _middleNameControllers) {
        controller.clear();
      }
      for (var controller in _lastNameControllers) {
        controller.clear();
      }
      for (var controller in _sectionControllers) {
        controller.clear();
      }

      // Reset to single empty child
      _children.clear();
      _children.add({
        'firstName': '',
        'middleName': '',
        'lastName': '',
        'section': ''
      });

      // Clear all controllers except the first one
      _firstNameControllers.removeRange(1, _firstNameControllers.length);
      _middleNameControllers.removeRange(1, _middleNameControllers.length);
      _lastNameControllers.removeRange(1, _lastNameControllers.length);
      _sectionControllers.removeRange(1, _sectionControllers.length);
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _firstNameControllers) {
      controller.dispose();
    }
    for (var controller in _middleNameControllers) {
      controller.dispose();
    }
    for (var controller in _lastNameControllers) {
      controller.dispose();
    }
    for (var controller in _sectionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(child: _buildChildrenList()),
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
          child: Stack(
            children: [
              Padding(
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
                      controller: _firstNameControllers[index],
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Please enter the child's first name" : null,
                      onSaved: (value) => _children[index]['firstName'] = value ?? '',
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _middleNameControllers[index],
                      decoration: const InputDecoration(
                        labelText: 'Middle Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Please enter the child's middle name" : null,
                      onSaved: (value) => _children[index]['middleName'] = value ?? '',
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _lastNameControllers[index],
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Please enter the child's last name" : null,
                      onSaved: (value) => _children[index]['lastName'] = value ?? '',
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _sectionControllers[index],
                      decoration: const InputDecoration(
                        labelText: 'Child Section',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Please enter the child's section" : null,
                      onSaved: (value) => _children[index]['section'] = value ?? '',
                    ),
                  ],
                ),
              ),
              if (index > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _removeChild(index),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _removeChild(int index) {
    setState(() {
      _children.removeAt(index);
      _firstNameControllers[index].dispose();
      _middleNameControllers[index].dispose();
      _lastNameControllers[index].dispose();
      _sectionControllers[index].dispose();
      
      _firstNameControllers.removeAt(index);
      _middleNameControllers.removeAt(index);
      _lastNameControllers.removeAt(index);
      _sectionControllers.removeAt(index);
    });
  }

  void _addAnotherChild() {
    setState(() {
      _children.add({
        'firstName': '',
        'middleName': '',
        'lastName': '',
        'section': ''
      });
      _addControllers();
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

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Success'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your request has been submitted successfully!',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please wait for teacher approval. You will be notified once your request is processed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _clearForm(); // Clear the form after closing the dialog
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
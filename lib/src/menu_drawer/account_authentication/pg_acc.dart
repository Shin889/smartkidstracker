import 'package:flutter/material.dart';
import 'package:smartkidstracker/src/general_acc/data_access/auth_controller.dart';

class PgAccScreen extends StatefulWidget {
  final String childName;
  final String userRole;
  final String schoolName;
  final String section;
  final AuthController authController = AuthController();

  PgAccScreen({super.key, required this.childName, required this.userRole, required this.schoolName, required this.section});

  @override
  _PgAccScreenState createState() => _PgAccScreenState();
}

class _PgAccScreenState extends State<PgAccScreen> {
  List<Map<String, dynamic>> _pendingChildren = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _loadPendingChildren();
  }

  Future<void> _loadPendingChildren() async {
    try {
      final children = await widget.authController.getPendingChildrenForSchool(widget.schoolName);
      setState(() {
        _pendingChildren = children;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading pending children: $e')));
    }
  }

  void _checkUserRole() {
    if (widget.userRole != 'Teacher' && widget.userRole != 'Admin') {
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access denied. Only teachers and admins can view this page.')),
        );
        Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.schoolName)),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _pendingChildren.isNotEmpty
              ? ListView.builder(
                  itemCount: _pendingChildren.length,
                  itemBuilder: (context, index) {
                    final child = _pendingChildren[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Name: ${child['name']}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Action'),
                              _buildActionButtons(child),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                )
              : const Center(
                  child: Text('No pending children'),
                ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> child) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => _handleConfirmation(child, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Confirm'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _handleConfirmation(child, false),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Reject'),
        ),
      ],
    );
  }

  Future<void> _handleConfirmation(Map<String, dynamic> child, bool confirmed) async {
    try {
      await widget.authController.updateChildStatus(child['id'], confirmed ? 'confirmed' : 'rejected');

      setState(() {
        _pendingChildren.remove(child);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(confirmed ? 'Child confirmed' : 'Child rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
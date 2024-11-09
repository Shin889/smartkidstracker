import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PgAccScreen extends StatefulWidget {
  final String childName;
  final String userRole;
  final String schoolName;
  final String section;

  const PgAccScreen({
    super.key,
    required this.childName,
    required this.userRole,
    required this.schoolName,
    required this.section,
  });

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
      final pendingChildrenSnapshot = await FirebaseFirestore.instance
          .collection('pending_children')
          .where('school', isEqualTo: widget.schoolName)
          .get();
      setState(() {
        _pendingChildren = pendingChildrenSnapshot.docs.map((doc) => doc.data()).toList();
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
          ? const Center(child: CircularProgressIndicator())
          : _pendingChildren.isNotEmpty
              ? ListView.builder(
                  itemCount: _pendingChildren.length,
                  itemBuilder: (context, index) {
                    final child = _pendingChildren[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${child['name']}', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Action'),
                              _buildActionButtons(child),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                )
              : const Center(child: Text('No pending children')),
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
      if (confirmed) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Remove child from pending_children collection
          final pendingChildRef = FirebaseFirestore.instance.collection('pending_children').doc(child['id']);
          transaction.delete(pendingChildRef);

          // Add child to confirmed_children collection
          final confirmedChildRef = FirebaseFirestore.instance.collection('confirmed_children').doc(child['id']);
          transaction.set(confirmedChildRef, {
            'name': child['name'],
            'school': widget.schoolName,
            'section': widget.section,
            'confirmedAt': FieldValue.serverTimestamp(),
          });
        });
      } else {
        await FirebaseFirestore.instance.collection('pending_children').doc(child['id']).update({
          'status': 'rejected',
        });
      }

      setState(() {
        _pendingChildren.remove(child);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(confirmed ? 'Child confirmed' : 'Child rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
    }
  }
}
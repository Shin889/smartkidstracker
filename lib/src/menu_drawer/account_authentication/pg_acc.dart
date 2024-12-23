import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PgAccScreen extends StatefulWidget {
  final String firstName;
  final String middleName;
  final String lastName;
  final String userRole;
  final String childSection;
  final String email;
  final String phone;

  const PgAccScreen({
    super.key,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.userRole,
    required this.childSection,
    required this.email,
    required this.phone,
  });

  @override
  _PgAccScreenState createState() => _PgAccScreenState();
}

class _PgAccScreenState extends State<PgAccScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('children').where('status', isEqualTo: 'Pending').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending children to be found'));
          }

          final pendingChildren = snapshot.data!.docs;

          return ListView.builder(
            itemCount: pendingChildren.length,
            itemBuilder: (context, index) {
              final data = pendingChildren[index].data() as Map<String, dynamic>;

              final firstName = data['firstName'] as String? ?? 'N/A';
              final middleName = data['middleName'] as String? ?? 'N/A';
              final lastName = data['lastName'] as String? ?? 'N/A';
              final childSection = data['childSection'] as String? ?? 'N/A';
              final createdAt = data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate().toLocal().toString()
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('First Name: $firstName'),
                      Text('Middle Name: $middleName'),
                      Text('Last Name: $lastName'),
                      Text('Section: $childSection'),
                      Text('Created At: $createdAt'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: _buildActionButtons(pendingChildren[index].id, data),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildActionButtons(String docId, Map<String, dynamic> data) {
    return [
      ElevatedButton(
        onPressed: () => _handleConfirmation(docId, data, true),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text('Confirm'),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: () => _showConfirmationDialog(docId), // Show confirmation dialog
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text('Reject'),
      ),
    ];
  }

  Future<void> _showConfirmationDialog(String docId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Rejection'),
          content: const Text('Are you sure you want to reject this application? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _handleRejection(docId); // Handle rejection and delete document
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRejection(String docId) async {
    try {
      // Delete the document from Firestore
      await FirebaseFirestore.instance.collection('children').doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application rejected and deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting application: $e')),
      );
    }
  }

  Future<void> _handleConfirmation(String docId, Map<String, dynamic> data, bool confirmed) async {
    try {
      if (confirmed) {
        final pendingChildRef = FirebaseFirestore.instance.collection('children').doc(docId);

        DocumentSnapshot childDocSnapshot = await pendingChildRef.get();

        if (childDocSnapshot.exists) {
          String parentId = childDocSnapshot['parentId'];

          await pendingChildRef.update({'status': 'Confirmed'});
          final parentRef = FirebaseFirestore.instance.collection('users').doc(parentId);
          await parentRef.update({'status': 'Confirmed'});
        }
      } else {
        await FirebaseFirestore.instance.collection('children').doc(docId).update({
          'status': 'Rejected',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(confirmed ? 'Application confirmed' : 'Application rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }
}

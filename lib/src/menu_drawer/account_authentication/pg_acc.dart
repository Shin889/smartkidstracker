import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PgAccScreen extends StatefulWidget {
  final String childName;
  final String userRole;
  final String childSchool;
  final String childSection;
  final String email;
  final String phone;

  const PgAccScreen({
    super.key,
    required this.childName,
    required this.userRole,
    required this.childSchool,
    required this.childSection,
    required this.email,
    required this.phone, required String schoolName,
  });

  @override
  _PgAccScreenState createState() => _PgAccScreenState();
}

class _PgAccScreenState extends State<PgAccScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pending_children').snapshots(),
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

              final childName = data['childName'] as String? ?? 'N/A';
              final childSchool = data['childSchool'] as String? ?? 'N/A';
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
                      Text(
                        'Child Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Name: $childName'),
                      Text('School: $childSchool'),
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
        onPressed: () => _handleConfirmation(docId, data, false),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text('Reject'),
      ),
    ];
  }

  Future<void> _handleConfirmation(String docId, Map<String, dynamic> data, bool confirmed) async {
    try {
      if (confirmed) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final pendingChildRef = FirebaseFirestore.instance.collection('pending_children').doc(docId);
          final confirmedChildRef = FirebaseFirestore.instance.collection('confirmed_children').doc();

          // Copy data to 'confirmed_children' and delete from 'pending_children'
          transaction.set(confirmedChildRef, {
            'childName': data['childName'],
            'childSchool': data['childSchool'],
            'childSection': data['childSection'],
            'email': data['email'], // Include email
            'phone': data['phone'], // Include phone
            'createdAt': data['createdAt'],
            'confirmedAt': FieldValue.serverTimestamp(),
          });
          transaction.delete(pendingChildRef);
        });
      } else {
        await FirebaseFirestore.instance.collection('pending_children').doc(docId).update({
          'status': 'rejected',
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

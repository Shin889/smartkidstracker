import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherAcc extends StatefulWidget {
  const TeacherAcc({super.key});

  @override
  State<TeacherAcc> createState() => _TeacherAccState();
}

class _TeacherAccState extends State<TeacherAcc> {
  // Track the IDs of confirmed teachers to update the UI
  final Set<String> confirmedTeachers = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Teacher')
          .where('status', isEqualTo: 'Pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final teachers = snapshot.data?.docs ?? [];

        if (teachers.isEmpty) {
          return const Center(child: Text('No pending teachers'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: teachers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final teacherData = teachers[index].data() as Map<String, dynamic>;
            final docId = teachers[index].id;
            final isConfirmed = confirmedTeachers.contains(docId);

            return TeacherInfoCard(
              teacherData: teacherData,
              isConfirmed: isConfirmed,
              onConfirm: isConfirmed
                  ? null
                  : () => _confirmTeacher(context, docId, teacherData),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmTeacher(BuildContext context, String docId, Map<String, dynamic> teacherData) async {
    try {
      print('Attempting to confirm teacher with ID: $docId');
      await FirestoreOperations.transferTeacherToConfirmed(docId, teacherData);
      print('Successfully confirmed teacher with ID: $docId');
      setState(() {
        confirmedTeachers.add(docId);
      });
      _showSuccessMessage(context, 'Teacher confirmed successfully!');
    } catch (e) {
      print('Error confirming teacher: $e');
      _showErrorMessage(context, e.toString());
    }
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $error')),
    );
  }
}

class TeacherInfoCard extends StatelessWidget {
  final Map<String, dynamic> teacherData;
  final bool isConfirmed;
  final VoidCallback? onConfirm;

  const TeacherInfoCard({
    super.key,
    required this.teacherData,
    required this.isConfirmed,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${teacherData['firstName'] ?? ''} ${teacherData['middleName'] ?? ''} ${teacherData['lastName'] ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, teacherData['email'] ?? 'N/A'),
            _buildInfoRow(Icons.phone, teacherData['phoneNumber'] ?? 'N/A'),
            _buildInfoRow(Icons.school, teacherData['school'] ?? 'N/A'),
            _buildInfoRow(Icons.class_, teacherData['section'] ?? 'N/A'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                isConfirmed
                    ? const Text(
                        'Confirmed',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      )
                    : ElevatedButton(
                        onPressed: onConfirm,
                        child: const Text('Confirm'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class FirestoreOperations {
  static Future<void> transferTeacherToConfirmed(String docId, Map<String, dynamic> teacherData) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final confirmedTeacherRef = firestore.collection('users').doc(docId);
      await confirmedTeacherRef.update({'status': 'Confirmed'});
    } catch (e) {
      print('Error transferring teacher in FirestoreOperations.transferTeacherToConfirmed(): $e');
      rethrow; // Ensure the error propagates to the calling function
    }
  }
}

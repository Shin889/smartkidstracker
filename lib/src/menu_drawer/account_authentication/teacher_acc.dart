import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherAcc extends StatelessWidget {
  const TeacherAcc({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pending_teachers')
          .where('status', isEqualTo: 'pending')
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
            return TeacherInfoCard(
              teacherData: teacherData,
              onConfirm: () => _confirmTeacher(context, teachers[index].id, teacherData),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmTeacher(BuildContext context, String docId, Map<String, dynamic> teacherData) async {
    try {
      await _showLoadingIndicator(context, () async {
        await FirestoreOperations.updateTeacherStatus(docId, teacherData);
      });

      _showSuccessMessage(context, 'Teacher confirmed successfully!');
    } catch (e) {
      print('Error confirming teacher: $e');
      _showErrorMessage(context, e.toString());
    }
  }

  Future<void> _showLoadingIndicator(BuildContext context, Future<void> Function() action) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await action();
    } finally {
      Navigator.of(context).pop();
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
  final VoidCallback onConfirm;

  const TeacherInfoCard({
    super.key,
    required this.teacherData,
    required this.onConfirm,
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
            _buildInfoRow(Icons.school, teacherData['section'] ?? 'N/A'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
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
  static Future<void> updateTeacherStatus(String docId, Map<String, dynamic> teacherData) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(FirebaseFirestore.instance.collection('pending_teachers').doc(docId), {
          'status': 'confirmed',
        });

        transaction.set(FirebaseFirestore.instance.collection('confirmed_teachers').doc(teacherData['userId'] ?? docId), {
          'firstName': teacherData['firstName'] ?? '',
          'middleName': teacherData['middleName'] ?? '',
          'lastName': teacherData['lastName'] ?? '',
          'email': teacherData['email'] ?? '',
          'phoneNumber': teacherData['phoneNumber'] ?? '',
          'school': teacherData['school'] ?? '',
          'section': teacherData['section'] ?? '',
        });
      });
    } catch (e) {
      print('Error updating teacher status in FirestoreOperations.updateTeacherStatus(): $e');
      rethrow;
    }
  }
}
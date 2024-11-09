import 'package:flutter/material.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/models/attendance.dart';
import '../services/firebase_service.dart';

class AttendanceDetailScreen extends StatelessWidget {
  final AttendanceRecord record;
  final FirebaseService firebaseService; // Add firebaseService parameter

  const AttendanceDetailScreen({
    super.key,
    required this.record,
    required this.firebaseService, // Make sure this is required
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${record.date} Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time In: ${record.timeIn}'),
            Text('Time Out: ${record.timeOut}'),
            // Additional details can be added here
          ],
        ),
      ),
    );
  }
}

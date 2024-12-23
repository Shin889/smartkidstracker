import 'package:flutter/material.dart';
import '../controller/constants.dart';
import '../model/student.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;
  const StudentCard({super.key, required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CONTROLLERCONSTANTS.nfc, size: CONTROLLERCONSTANTS.iconSize),
              Text(student.firstName, style: CONTROLLERCONSTANTS.rfidTextStyle),
              Text(student.section),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceSuccessSnackbar {
  final BuildContext context;

  AttendanceSuccessSnackbar(this.context);

  void showTaggedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance has been recorded.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class AttendanceErrorSnackbar {
  final BuildContext context;

  AttendanceErrorSnackbar(this.context);

  void showTaggedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance has not been recorded.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('An error occurred while processing attendance.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
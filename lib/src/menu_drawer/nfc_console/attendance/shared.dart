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
              Text(student.name, style: CONTROLLERCONSTANTS.rfidTextStyle),
              Text(student.section),
              Text(student.school),
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

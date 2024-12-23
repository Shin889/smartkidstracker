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
        color: student.rfidNumber.isNotEmpty ? Colors.green[300] : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CONTROLLERCONSTANTS.nfc, size: CONTROLLERCONSTANTS.iconSize),
            Text(
              '${student.firstName} ${student.middleName} ${student.lastName}'.trim(),
              style: CONTROLLERCONSTANTS.rfidTextStyle,
            ),
            Text(student.section),
          ],
        ),
      ),
    ),
  );
}
}


class RfidSuccessSnackbar {
  final BuildContext context;

  RfidSuccessSnackbar(this.context);

  void showTaggedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('NFC number has been tagged.'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

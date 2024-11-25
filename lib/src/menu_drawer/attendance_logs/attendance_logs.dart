import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_logs/constants.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_logs/controller.dart';

import 'shared.dart';

class AttendanceLogs extends StatefulWidget {
  final String section;
  final String role;
  final String email;

  const AttendanceLogs({
    super.key,
    required this.section,
    required this.role,
    required this.email,
  });

  @override
  State<AttendanceLogs> createState() => _AttendanceLogsState();
}

class _AttendanceLogsState extends State<AttendanceLogs> {
  var attendanceContoller = AttendanceController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
      stream: attendanceContoller.streamCollection('attendance'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ReturnLoading();
        } else if (snapshot.hasError) {
          return ReturnText(message: ATTENDANCELOGSCONTANTS.errorText);
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return ReturnText(message: ATTENDANCELOGSCONTANTS.noStudentsText);
        } else {
          final attendance = attendanceContoller.getLogs(
              snapshot.data!, widget.email, widget.role, widget.section);
          return ListView.builder(
            itemCount: attendance.length,
            itemBuilder: (context, index) {
              final student = attendance[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${student['name']}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Attendance Type: ${student['attendance']}',
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text('RFID Number: ${student['rfidNumber']}',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    ));
  }
}

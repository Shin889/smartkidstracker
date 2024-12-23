import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final attendanceContoller = AttendanceController();

  String formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return DateFormat("d MMMM yyyy 'at' HH:mm:ss").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;

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

            // Sort by timestamp (recent logs first)
            attendance.sort((a, b) {
              final aTimestamp = a['timestamp'] as Timestamp;
              final bTimestamp = b['timestamp'] as Timestamp;
              return bTimestamp.compareTo(aTimestamp);
            });

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              itemCount: attendance.length,
              itemBuilder: (context, index) {
                final student = attendance[index];
                final timestamp = student['timestamp'] as Timestamp?;
                final formattedTimestamp = timestamp != null
                    ? formatTimestamp(timestamp)
                    : 'No timestamp available';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'] ?? 'Unknown Name',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Row(
                          children: [
                            Icon(Icons.fingerprint,
                                color: Colors.blue, size: screenWidth * 0.05),
                            SizedBox(width: screenWidth * 0.03),
                            Flexible(
                              child: Text(
                                "NFC Number: ${student['rfidNumber'] ?? 'N/A'}",
                                style: TextStyle(fontSize: screenWidth * 0.04),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Row(
                          children: [
                            Icon(Icons.event,
                                color: Colors.green, size: screenWidth * 0.05),
                            SizedBox(width: screenWidth * 0.03),
                            Flexible(
                              child: Text(
                                "Attendance: ${student['attendance'] ?? 'N/A'}",
                                style: TextStyle(fontSize: screenWidth * 0.04),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                color: Colors.orange,
                                size: screenWidth * 0.05),
                            SizedBox(width: screenWidth * 0.03),
                            Flexible(
                              child: Text(
                                "Timestamp: $formattedTimestamp",
                                style: TextStyle(fontSize: screenWidth * 0.04),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

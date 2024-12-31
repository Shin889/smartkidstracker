import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  final String userDocId;

  const AttendanceScreen({
    required this.userDocId,
    super.key,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String searchQuery = "";

  void filterAttendance(String query, List<Map<String, dynamic>> attendanceData) {
    setState(() {
      searchQuery = query;
    });
  }

  List<Map<String, dynamic>> getFilteredData(
      List<Map<String, dynamic>> attendanceData) {
    if (searchQuery.isEmpty) {
      return attendanceData;
    } else {
      return attendanceData.where((record) {
        final name = record['name']?.toLowerCase() ?? '';

        return name.contains(searchQuery.toLowerCase());
      }).toList();
    }
  }

  Map<String, Map<String, dynamic>> getLatestAttendance(
      List<QueryDocumentSnapshot> docs) {
    final Map<String, Map<String, dynamic>> latestRecords = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final email = data['email'];
      final timestamp = (data['timestamp'] as Timestamp).toDate();

      if (!latestRecords.containsKey(email) ||
          (latestRecords[email]!['timestamp'] as Timestamp)
              .toDate()
              .isBefore(timestamp)) {
        data['docId'] = doc.id;
        latestRecords[email] = data;
      }
    }

    return latestRecords;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Name or Date',
                border: OutlineInputBorder(),
              ),
              onChanged: (query) => filterAttendance(query, []),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .orderBy('email')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No attendance records found'),
                  );
                }

                // Fetch and process attendance data from Firestore
                final attendanceData =
                getLatestAttendance(snapshot.data!.docs).values.toList();
                final filteredData = getFilteredData(attendanceData);

                if (filteredData.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No attendance records found'),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey),
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Colors.lightBlueAccent),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Name',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Status',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                      ...filteredData.map((record) {
                        final name = record['name'] ?? 'Unknown';
                        final timestamp =
                        (record['timestamp'] as Timestamp).toDate();
                        final formattedDate =
                        DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);

                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name),
                                  Text(
                                    "Section: ${record['section'] ?? 'Unknown Section'}",
                                    style: const TextStyle(color: Colors.blueGrey),
                                  ),
                                ],
                              ),
                            ),
                            record['attendance'] == 'tap-out'
                                ?  Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  Text(formattedDate, style: TextStyle(fontSize: 10),)
                                ],
                              ),
                            )
                                : const SizedBox(),
                          ],
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

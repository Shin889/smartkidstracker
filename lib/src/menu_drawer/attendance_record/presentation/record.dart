import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<Map<String, dynamic>> attendanceData = [];
  List<Map<String, dynamic>> filteredData = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  Future<void> fetchAttendanceData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .where('attendance', isEqualTo: 'tap-in')
          .orderBy('timestamp', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          attendanceData = snapshot.docs.map((doc) {
            var data = doc.data();
            data['docId'] = doc.id;
            return data;
          }).toList();
          filteredData = attendanceData;
        });
      } else {
        setState(() {
          attendanceData = [];
          filteredData = [];
        });
      }
    } catch (e) {
      print('Error fetching attendance data: $e');
      setState(() {
        attendanceData = [];
        filteredData = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterAttendance(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredData = attendanceData;
      } else {
        filteredData = attendanceData.where((record) {
          final name = record['name']?.toLowerCase() ?? '';
          final date = (record['timestamp'] as Timestamp).toDate().toString().toLowerCase();
          return name.contains(query.toLowerCase()) || date.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search by Name or Date',
                  border: OutlineInputBorder(),
                ),
                onChanged: filterAttendance,
              ),
            ),
            filteredData.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No attendance records found'),
                    ),
                  )
                : Padding(
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
                                      fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Status',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ),
                        ...filteredData.map((record) {
                          final name = record['name'] ?? 'Unknown';
                          final timestamp =
                              (record['timestamp'] as Timestamp).toDate();

                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name),
                                    Text(
                                      '${timestamp.day.toString().padLeft(2, '0')}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.year}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

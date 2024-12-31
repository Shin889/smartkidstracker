import 'package:date_picker_timeline/date_picker_widget.dart';
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
  final DatePickerController _controller = DatePickerController();
  DateTime selectedDate = DateTime.now();

  void filterAttendance(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  Map<String, Map<String, dynamic>> getLatestAttendance(
      List<QueryDocumentSnapshot> docs) {
    final Map<String, Map<String, dynamic>> latestTapInRecords = {};
    final Map<String, Map<String, dynamic>> latestTapOutRecords = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final email = data['email'];
      final attendanceType = data['attendance'];
      final timestamp = (data['timestamp'] as Timestamp).toDate();

      if (attendanceType == 'tap-in') {
        if (!latestTapInRecords.containsKey(email) ||
            (latestTapInRecords[email]!['timestamp'] as Timestamp)
                .toDate()
                .isBefore(timestamp)) {
          data['docId'] = doc.id;
          latestTapInRecords[email] = data;
        }
      } else if (attendanceType == 'tap-out') {
        if (!latestTapOutRecords.containsKey(email) ||
            (latestTapOutRecords[email]!['timestamp'] as Timestamp)
                .toDate()
                .isBefore(timestamp)) {
          data['docId'] = doc.id;
          latestTapOutRecords[email] = data;
        }
      }
    }

    // Combine latest tap-in and tap-out records
    final Map<String, Map<String, dynamic>> combinedRecords = {};
    latestTapInRecords.forEach((email, tapInData) {
      combinedRecords[email] = {
        'tap-in': tapInData,
        'tap-out': latestTapOutRecords[email],
      };
    });

    return combinedRecords;
  }

  List<Map<String, dynamic>> getFilteredData(
      List<Map<String, dynamic>> combinedAttendanceData) {
    if (searchQuery.isEmpty) {
      return combinedAttendanceData;
    } else {
      return combinedAttendanceData
          .where((record) {
        final tapInName =
            record['tap-in']?['name']?.toLowerCase() ?? '';
        final tapOutName =
            record['tap-out']?['name']?.toLowerCase() ?? '';

        return tapInName.contains(searchQuery.toLowerCase()) ||
            tapOutName.contains(searchQuery.toLowerCase());
      })
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();

    // Scroll to the initial selected date after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.animateToDate(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    return Scaffold(
      body: Column(
        children: [
          DatePicker(
            DateTime.now().subtract(const Duration(days: 365)),
            daysCount: 366,
            controller: _controller,
            height: 100,
            initialSelectedDate: selectedDate,
            selectionColor: Colors.black,
            selectedTextColor: Colors.white,
            onDateChange: (date) {
              setState(() {
                selectedDate = date;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Name',
                border: OutlineInputBorder(),
              ),
              onChanged: filterAttendance,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
                  .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
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
                final combinedAttendanceData =
                getLatestAttendance(snapshot.data!.docs).values.toList();
                final filteredData = getFilteredData(combinedAttendanceData);

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
                      2: FlexColumnWidth(2),
                    },
                    children: [
                      const TableRow(
                        decoration:
                        BoxDecoration(color: Colors.lightBlueAccent),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Name',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Tap-In Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Tap-Out Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      ...filteredData.map((record) {
                        final tapInRecord = record['tap-in'];
                        final tapOutRecord = record['tap-out'];

                        final name = tapInRecord?['name'] ??
                            tapOutRecord?['name'] ??
                            'Unknown';
                        final tapInTime = tapInRecord != null
                            ? DateFormat('HH:mm:ss').format(
                            (tapInRecord['timestamp'] as Timestamp)
                                .toDate())
                            : '--';
                        final tapOutTime = tapOutRecord != null
                            ? DateFormat('HH:mm:ss').format(
                            (tapOutRecord['timestamp'] as Timestamp)
                                .toDate())
                            : '--';

                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(name),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(tapInTime),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(tapOutTime),
                            ),
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

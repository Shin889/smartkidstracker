import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/controllers/attendance.dart'; // Adjust the path if needed
 
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, required this.section, required String userRole});

  final String section; // Section name to load attendance records for

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceRecordController _attendanceController = AttendanceRecordController();
  final List<Map<String, dynamic>> _attendanceRecords = [];
  bool _hasMore = true; // Indicates if there are more records to load
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  final int _limit = 10; // Adjust the number of records per page

  @override
  void initState() {
    super.initState();
    _fetchAttendanceRecords();
  }

  // Fetch records with pagination
  Future<void> _fetchAttendanceRecords() async {
    if (_isLoading || !_hasMore) return; // Prevent multiple fetch calls

    setState(() {
      _isLoading = true;
    });

    List<Map<String, dynamic>> newRecords = await _attendanceController.fetchAttendanceRecords(
      widget.section,
      _lastDocument,
      _limit,
    );

    if (newRecords.isNotEmpty) {
      setState(() {
        _attendanceRecords.addAll(newRecords);
        _lastDocument = newRecords.last['timestamp'];
      });
    } else {
      setState(() {
        _hasMore = false; // No more records to fetch
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Archive old records
  Future<void> _archiveOldRecords() async {
    DateTime cutoffDate = DateTime.now().subtract(Duration(days: 30)); // Archive records older than 30 days
    await _attendanceController.archiveOldAttendanceRecords(widget.section, cutoffDate);
    setState(() {
      _attendanceRecords.removeWhere((record) => record['timestamp'].toDate().isBefore(cutoffDate));
    });
  }

  // List Item for each record
  Widget _buildAttendanceRecordItem(Map<String, dynamic> record) {
    return ListTile(
      title: Text("ID: ${record['id']}"),
      subtitle: Text("Status: ${record['status']}"),
      trailing: Text("Date: ${record['timestamp'].toDate().toLocal()}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance for ${widget.section}'),
        actions: [
          IconButton(
            icon: Icon(Icons.archive),
            onPressed: _archiveOldRecords,
            tooltip: "Archive old records",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _attendanceRecords.length + 1,
              itemBuilder: (context, index) {
                if (index < _attendanceRecords.length) {
                  return _buildAttendanceRecordItem(_attendanceRecords[index]);
                } else if (_hasMore) {
                  // Fetch next set of records when reaching end of list
                  _fetchAttendanceRecords();
                  return Center(child: CircularProgressIndicator());
                } else {
                  return Center(child: Text("No more records"));
                }
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

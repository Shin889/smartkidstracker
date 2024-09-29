import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/models/student.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/services/firebase_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<AttendanceRecord> attendanceRecords = [];
  bool isScanning = false;

  Future<void> handleNfcScan() async {
    if (!isScanning) {
      setState(() {
        isScanning = true;
      });
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final nfcData = _extractNfcData(tag);
          if (nfcData != null) {
            final student = await _firebaseService.getStudentByNfc(nfcData['nfcId']!);
            if (student != null) {
              // Check if the student is already recorded for today
              final now = DateTime.now();
              final dateString = now.toString().split(' ')[0];
              final existingRecordIndex = attendanceRecords.indexWhere((record) =>
                  record.nfcId == nfcData['nfcId'] && record.date == dateString);

              if (existingRecordIndex == -1) {
                // New record for timeIn
                _addAttendanceRecord(student, nfcData['nfcId']!, true);
                await _firebaseService.logAttendance(student.studentId, student.sectionId); // Log attendance for timeIn
              } else {
                // Existing record found, update timeOut
                _updateAttendanceRecord(existingRecordIndex, now.toString().split(' ')[1]);
                await _firebaseService.logAttendance(student.studentId, student.sectionId); // Log attendance for timeOut
              }
            } else {
              _showSnackBar('Student not found for NFC ID: ${nfcData['nfcId']}');
            }
          } else {
            _showSnackBar('NFC data extraction failed');
          }
        },
      );
    } else {
      await NfcManager.instance.stopSession();
    }
    setState(() {
      isScanning = !isScanning; // Toggle scanning state
    });
  }

  // Method to extract custom NDEF data from NFC Tag
  Map<String, String>? _extractNfcData(NfcTag tag) {
    try {
      final ndefMessage = tag.data['ndef']?['cachedMessage'];
      if (ndefMessage != null) {
        final records = ndefMessage['records'] as List<dynamic>;
        final Map<String, String> extractedData = {};
        for (var record in records) {
          final type = String.fromCharCodes(record['type']);
          final payload = String.fromCharCodes(record['payload']);
          
          if (type.contains('T')) { // Assuming 'T' type for Text records
            final keyValue = payload.substring(3); // Skipping language code bytes
            final parts = keyValue.split(':'); // Custom format key:value
            if (parts.length == 2) {
              extractedData[parts[0]] = parts[1];
            }
          }
        }
        return extractedData;
      }
    } catch (e) {
      print("Error extracting NDEF data: $e");
    }
    return null;
  }

  void _addAttendanceRecord(Student student, String nfcId, bool isTimeIn) {
    final now = DateTime.now();
    setState(() {
      attendanceRecords.add(AttendanceRecord(
        name: student.name,
        date: now.toString().split(' ')[0],
        timeIn: isTimeIn ? now.toString().split(' ')[1] : '',
        timeOut: isTimeIn ? '' : now.toString().split(' ')[1],
        nfcId: nfcId,
      ));
    });
  }

  void _updateAttendanceRecord(int index, String timeOut) {
    setState(() {
      attendanceRecords[index].timeOut = timeOut; // Update the existing record's timeOut
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Read box
            GestureDetector(
              onTap: handleNfcScan,
              child: Container(
                color: Colors.blue,
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    isScanning ? 'Scanning' : 'Read',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Write box
            Container(
              color: Colors.green,
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Write',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Attendance History box
            Container(
              color: Colors.orange,
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Attendance History',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Attendance Record box
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Time In')),
                  DataColumn(label: Text('Time Out')),
                ],
                rows: attendanceRecords.map((record) {
                  return DataRow(cells: [
                    DataCell(
                      Text(record.name),
                      onTap: () => _navigateToDetailScreen(record),
                    ),
                    DataCell(Text(record.date)),
                    DataCell(Text(record.timeIn)),
                    DataCell(Text(record.timeOut)),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetailScreen(AttendanceRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceDetailScreen(record: record),
      ),
    );
  }
}

class AttendanceDetailScreen extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Record Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${record.name}'),
            Text('Date: ${record.date}'),
            Text('Time In: ${record.timeIn}'),
            Text('Time Out: ${record.timeOut}'),
            Text('NFC ID: ${record.nfcId}'),
          ],
        ),
      ),
    );
  }
}

class AttendanceRecord {
  final String name;
  final String date;
  String timeIn; // Changed to mutable
  String timeOut; // Changed to mutable
  final String nfcId;

  AttendanceRecord({
    required this.name,
    required this.date,
    required this.timeIn,
    required this.timeOut,
    required this.nfcId,
  });
}

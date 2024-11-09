import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecordController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Record attendance for a specific section
  Future<void> recordAttendance(String tagId, String teacherSection) async {
    try {
      // Search for the section in 'confirmed_teachers'
      QuerySnapshot teacherSnapshot = await _firestore
          .collection('confirmed_teachers')
          .where('section', isEqualTo: teacherSection)
          .get();

      if (teacherSnapshot.docs.isNotEmpty) {
        // Pass the attendance data to the specific section's attendance record
        await _firestore
            .collection('attendance')
            .doc(teacherSection)
            .collection('records')
            .add({
          'id': tagId,
          'timestamp': Timestamp.now(),
          'status': 'Present',
        });
        print("Attendance recorded successfully for section: $teacherSection");
      } else {
        print("No matching section found for teacher.");
      }
    } catch (e) {
      print("Error recording attendance: $e");
    }
  }

  // Fetch attendance records with pagination
  Future<List<Map<String, dynamic>>> fetchAttendanceRecords(
      String section, DocumentSnapshot? lastDoc, int limit) async {
    try {
      Query query = _firestore
          .collection('attendance')
          .doc(section)
          .collection('records')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching attendance records: $e");
      return [];
    }
  }

  // Archive old attendance records for a section
  Future<void> archiveOldAttendanceRecords(String section, DateTime cutoffDate) async {
    try {
      QuerySnapshot oldRecordsSnapshot = await _firestore
          .collection('attendance')
          .doc(section)
          .collection('records')
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      for (var doc in oldRecordsSnapshot.docs) {
        // Move to archived records
        await _firestore
            .collection('attendance')
            .doc(section)
            .collection('archived_records')
            .doc(doc.id)
            .set(doc.data() as Map<String, dynamic>); // Casting added here

        // Delete from active records
        await doc.reference.delete();
      }

      print("Old records archived successfully for section: $section");
    } catch (e) {
      print("Error archiving old attendance records: $e");
    }
  }
}

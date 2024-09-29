import 'package:firebase_database/firebase_database.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/models/student.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref(); // Updated to use ref() instead of reference()

  Future<Student?> getStudentByNfc(String nfcId) async {
    final snapshot = await _db
        .child('Students')
        .orderByChild('nfcId')
        .equalTo(nfcId)
        .once();

    if (snapshot.snapshot.exists) { // Check if the snapshot exists
      final studentData = Map<String, dynamic>.from(snapshot.snapshot.value as Map); // Cast to Map
      return Student.fromJson(studentData);
    }
    return null;
  }

  Future<void> logAttendance(String studentId, String sectionId) async {
    final attendanceRecord = {
      'studentId': studentId,
      'sectionId': sectionId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _db.child('Attendance').push().set(attendanceRecord);
  }
}
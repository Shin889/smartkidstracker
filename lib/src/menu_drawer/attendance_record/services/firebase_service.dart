import 'package:firebase_database/firebase_database.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/models/student.dart';
import 'package:smartkidstracker/src/menu_drawer/attendance_record/models/attendance.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> logAttendance(String studentId, String sectionId, String name) async {
    try {
      final now = DateTime.now();
      final attendanceRecord = AttendanceRecord(
        name: name,
        date: now.toIso8601String().split('T')[0],
        timeIn: now.toIso8601String().split('T')[1].substring(0, 5),
        timeOut: '',
      ).toJson();

      final newAttendanceRef = _db.child('attendance').push();
      await newAttendanceRef.set(attendanceRecord);

      // Save the generated attendance ID back to the database if needed
      await newAttendanceRef.update({
        'attendanceId': newAttendanceRef.key,
        'studentId': studentId,
        'sectionId': sectionId,
      });
    } catch (e) {
      print('Error logging attendance: $e');
      throw Exception('Failed to log attendance: $e');
    }
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsByRole(String userId, String role, {int? limit}) async {
    try {
      if (role == 'Teacher') {
        final sectionId = await getSectionIdByTeacher(userId);
        return await getAttendanceRecordsBySection(sectionId, limit: limit);
      } else if (role == 'Parent') {
        return await getAttendanceRecordsForParent(userId, limit: limit);
      } else {
        throw Exception('Invalid user role');
      }
    } catch (e) {
      print('Error fetching attendance records: $e');
      rethrow;
    }
  }

  Future<List<AttendanceRecord>> getAllAttendanceRecords(int? limit) async {
    Query query = _db.child('attendance');
    
    if (limit != null) {
      query = query.limitToLast(limit);
    }

    final snapshot = await query.get();
    return _processAttendanceSnapshot(snapshot);
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsBySection(String sectionId, {int? limit}) async {
    Query query = _db.child('attendance').orderByChild('sectionId').equalTo(sectionId);
    
    if (limit != null) {
      query = query.limitToLast(limit);
    }

    final snapshot = await query.get();
    return _processAttendanceSnapshot(snapshot);
  }

  Future<List<AttendanceRecord>> getAttendanceRecordsForParent(String parentId, {int? limit}) async {
    final children = await fetchChildrenByParent(parentId);
    List<AttendanceRecord> allAttendance = [];

    for (var child in children) {
      final records = await getAttendanceRecordsBySection(child.sectionId, limit: limit);
      allAttendance.addAll(records);
    }

    return allAttendance;
  }

  Future<List<Student>> fetchChildrenByParent(String parentId) async {
    final snapshot = await _db.child('Students').orderByChild('parentId').equalTo(parentId).get();
    if (snapshot.exists) {
      final studentsData = snapshot.value as Map<dynamic, dynamic>;
      return studentsData.entries
          .map((entry) => Student.fromJson({
                'studentId': entry.key,
                ...Map<String, dynamic>.from(entry.value as Map),
              }))
          .toList();
    }
    return [];
  }

  Future<String> getSectionIdByTeacher(String teacherId) async {
    final sectionSnapshot = await _db.child('Sections').orderByChild('teacherId').equalTo(teacherId).get();
    if (sectionSnapshot.exists && sectionSnapshot.children.isNotEmpty) {
      return sectionSnapshot.children.first.key ?? '';
    }
    throw Exception('No section found for teacher: $teacherId');
  }

  Future<List<AttendanceRecord>> _processAttendanceSnapshot(DataSnapshot snapshot) async {
    if (snapshot.exists) {
      final recordsData = snapshot.value as Map<dynamic, dynamic>;
      return recordsData.entries
          .map((entry) => AttendanceRecord.fromJson({
                'attendanceId': entry.key,
                ...Map<String, dynamic>.from(entry.value as Map),
              }))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
    } else {
      print('No attendance records found');
    }
    return [];
  }

  Future<List<Student>> fetchStudentsBySection(String sectionId) async {
    final snapshot = await _db.child('Students').orderByChild('sectionId').equalTo(sectionId).get();
    if (snapshot.exists) {
      final studentsData = snapshot.value as Map<dynamic, dynamic>;
      return studentsData.entries
          .map((entry) => Student.fromJson({
                'studentId': entry.key,
                ...Map<String, dynamic>.from(entry.value as Map),
              }))
          .toList();
    }
    return [];
  }

  Stream<List<AttendanceRecord>> streamRecentAttendance(String sectionId) {
    return _db.child('attendance')
        .orderByChild('sectionId')
        .equalTo(sectionId)
        .limitToLast(10)
        .onValue
        .map((event) {
          if (event.snapshot.value != null) {
            final recordsData = event.snapshot.value as Map<dynamic, dynamic>;
            return recordsData.entries
                .map((entry) => AttendanceRecord.fromJson({
                      'attendanceId': entry.key,
                      ...Map<String, dynamic>.from(entry.value as Map),
                    }))
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
          }
          return [];
        });
  }

  Future<void> updateStudentInfo(String studentId, Map<String, dynamic> updates) async {
    try {
      await _db.child('Students').child(studentId).update(updates);
    } catch (e) {
      print('Error updating student info: $e');
      throw Exception('Failed to update student info: $e');
    }
  }
}
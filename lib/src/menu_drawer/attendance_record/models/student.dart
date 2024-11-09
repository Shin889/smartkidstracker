import 'package:smartkidstracker/src/menu_drawer/attendance_record/models/attendance.dart';

class Student {
  final String studentId;
  final String name;
  final String nfcId;
  final String sectionId;
  final List<AttendanceRecord> attendanceRecords;

  Student({
    required this.studentId,
    required this.name,
    required this.nfcId,
    required this.sectionId,
    this.attendanceRecords = const [], required String id,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] as String,
      name: json['name'] as String,
      nfcId: json['nfcId'] as String,
      sectionId: json['sectionId'] as String,
      attendanceRecords: (json['attendanceRecords'] as List<dynamic>?)
          ?.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList() ?? [], id: '',
    );
  }

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'name': name,
    'nfcId': nfcId,
    'sectionId': sectionId,
    'attendanceRecords': attendanceRecords.map((e) => e.toJson()).toList(),
  };
}

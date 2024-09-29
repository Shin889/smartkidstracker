class Attendance {
  String attendanceId;
  String studentId;
  String sectionId;
  DateTime timestamp;

  Attendance({required this.attendanceId, required this.studentId, required this.sectionId, required this.timestamp});

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceId: json['attendanceId'],
      studentId: json['studentId'],
      sectionId: json['sectionId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
class AttendanceRecord {
  final String name;
  final String date;
  final String timeIn;
  final String timeOut;

  AttendanceRecord({
    required this.name,
    required this.date,
    required this.timeIn,
    required this.timeOut,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      name: json['name'] as String,
      date: json['date'] as String,
      timeIn: json['timeIn'] as String,
      timeOut: json['timeOut'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date,
    'timeIn': timeIn,
    'timeOut': timeOut,
  };
}

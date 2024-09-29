class School {
  String schoolId;
  String schoolName;

  School({required this.schoolId, required this.schoolName});

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      schoolId: json['schoolId'],
      schoolName: json['schoolName'],
    );
  }
}
class School {
  String schoolId;
  String schoolName;

  School({
    required this.schoolId,
    required this.schoolName,
  });

  // Convert a JSON map to a School object
  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      schoolId: json['schoolId'] as String,
      schoolName: json['schoolName'] as String,
    );
  }

  // Convert a School object to a JSON map
  Map<String, dynamic> toJson() => {
    'schoolId': schoolId,
    'schoolName': schoolName,
  };
}

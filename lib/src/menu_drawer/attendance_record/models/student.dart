class Student {
  String studentId;
  String name;
  String nfcId;
  String sectionId;

  Student({required this.studentId, required this.name, required this.nfcId, required this.sectionId});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'],
      name: json['name'],
      nfcId: json['nfcId'],
      sectionId: json['sectionId'],
    );
  }
}
class Student {
  final String id;
  final String name;
  final String section;
  final String email;
  final String school;
  final String rfidNumber;

  Student(
      {required this.id,
      required this.name,
      required this.section,
      required this.school,
      required this.email,
      required this.rfidNumber});

  factory Student.fromMap(Map<String, dynamic> data, String id) {
    return Student(
      id: id,
      name: data['childName'] ?? '',
      section: data['childSection'] ?? '',
      school: data['childSchool'] ?? '',
      email: data['email'] ?? '',
      rfidNumber: data['rfidNumber'] ?? '',
    );
  }
}

class Student {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String section;
  final String email;
  final String rfidNumber;

  Student(
      {required this.id,
      required this.firstName,
      required this.middleName,
      required this.lastName,
      required this.section,
      required this.email,
      required this.rfidNumber});

  factory Student.fromMap(Map<String, dynamic> data, String id) {
    return Student(
      id: id,
      firstName: data['firstName'] ?? '',
      middleName: data['middleName'] ?? '',
      lastName: data['lastName'] ?? '',
      section: data['section'] ?? '',
      email: data['email'] ?? '',
      rfidNumber: data['rfidNumber'] ?? '',
    );
  }
}

class Section {
  String sectionId;
  String sectionName;
  String schoolId;
  String teacherId;  // Added teacherId to represent the assigned teacher

  Section({
    required this.sectionId,
    required this.sectionName,
    required this.schoolId,
    required this.teacherId,  // Include teacherId in the constructor
  });

  // Convert a JSON map to a Section object
  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionId: json['sectionId'] as String,
      sectionName: json['sectionName'] as String,
      schoolId: json['schoolId'] as String,
      teacherId: json['teacherId'] as String,  // Retrieve teacherId from JSON
    );
  }

  // Convert a Section object to a JSON map
  Map<String, dynamic> toJson() => {
    'sectionId': sectionId,
    'sectionName': sectionName,
    'schoolId': schoolId,
    'teacherId': teacherId,  // Include teacherId in the JSON
  };
}

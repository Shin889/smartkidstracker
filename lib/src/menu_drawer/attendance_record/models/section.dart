class Section {
  String sectionId;
  String sectionName;
  String schoolId;

  Section({required this.sectionId, required this.sectionName, required this.schoolId});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionId: json['sectionId'],
      sectionName: json['sectionName'],
      schoolId: json['schoolId'],
    );
  }
}
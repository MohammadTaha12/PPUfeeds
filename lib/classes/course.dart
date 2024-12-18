class Course {
  final int id;
  final String name;
  final String college;
  final int collegeId;

  Course({
    required this.id,
    required this.name,
    required this.college,
    required this.collegeId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      college: json['college'],
      collegeId: json['college_id'],
    );
  }
}

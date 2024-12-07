class Course {
  final int id;
  final String name;
  final String college;
  final List<dynamic> sections; 

  Course({
    required this.id,
    required this.name,
    required this.college,
    this.sections = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      college: json['college'],
      sections: json['sections'] ?? [],
    );
  }
}

class Section {
  final int id;
  final String name;
  final String lecturer;
  bool isSubscribed; // تحديد حالة الاشتراك

  Section({
    required this.id,
    required this.name,
    required this.lecturer,
    this.isSubscribed = false, // القيمة الافتراضية false
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      name: json['name'],
      lecturer: json['lecturer'],
      isSubscribed: false, // القيمة تُحدَّث لاحقًا بناءً على حالة الاشتراك
    );
  }
}

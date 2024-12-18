class Subscription {
  final int id;
  final String sectionName;
  final String courseName;
  final String lecturer;
  final String subscriptionDate;

  Subscription({
    required this.id,
    required this.sectionName,
    required this.courseName,
    required this.lecturer,
    required this.subscriptionDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      sectionName: json['section'],
      courseName: json['course'],
      lecturer: json['lecturer'],
      subscriptionDate: json['subscription_date'],
    );
  }
}

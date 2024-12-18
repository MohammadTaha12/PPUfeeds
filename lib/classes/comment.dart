class Comment {
  final int id;
  final String body;
  final String datePosted;
  final String author;
  int likesCount; // عدد اللايكات
  bool isLiked; // حالة الإعجاب

  Comment({
    required this.id,
    required this.body,
    required this.datePosted,
    required this.author,
    this.likesCount = 0,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0, // وضع قيمة افتراضية 0 في حال كان null
      body: json['body'] ?? "No content", // نص افتراضي في حال كان null
      datePosted: json['date_posted'] ?? "Unknown date",
      author: json['author'] ?? "Unknown author",
      likesCount: json['likes_count'] ?? 0, // قيمة افتراضية 0 لعدد اللايكات
      isLiked: json['liked'] ?? false, // قيمة افتراضية false لحالة الإعجاب
    );
  }
}

class Comment {
  int id;
  String body;
  String datePosted;
  String author;
  bool isLiked;
  int likesCount;

  Comment({
    required this.id,
    required this.body,
    required this.datePosted,
    required this.author,
    this.isLiked = false,
    this.likesCount = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      body: json['body'] ?? "No content",
      datePosted: json['date_posted'] ?? "Unknown date",
      author: json['author'] ?? "Unknown author",
      isLiked: json['liked'] ?? false,
      likesCount: json['likes_count'] ?? 0,
    );
  }
}

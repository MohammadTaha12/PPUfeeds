class Comment {
  final int id;
  final String body;
  final String datePosted;
  final String author;
  int likesCount;
  bool isLiked;

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
      id: json['id'] ?? 0,
      body: json['body'] ?? "No content",
      datePosted: json['date_posted'] ?? "Unknown date",
      author: json['author'] ?? "Unknown author",
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['liked'] ?? false,
    );
  }
}

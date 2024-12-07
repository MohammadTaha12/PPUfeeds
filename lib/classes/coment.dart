class Comment {
  final int id;
  final String body;
  final String datePosted;
  final String userName;
  bool liked;
  int likesCount;

  Comment({
    required this.id,
    required this.body,
    required this.datePosted,
    required this.userName,
    this.liked = false,
    this.likesCount = 0,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      body: json['body'] ?? 'No content',
      datePosted: json['date_posted'] ?? '',
      userName: json['user_name'] ?? 'Unknown User',
      liked: json['liked'] ?? false,
      likesCount: json['likes_count'] ?? 0,
    );
  }
}

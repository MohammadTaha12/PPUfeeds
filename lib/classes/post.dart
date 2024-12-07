class Post {
  final int id;
  final String body;
  final String datePosted;
  final String lecturerName;
  final int commentsCount;

  Post({
    required this.id,
    required this.body,
    required this.datePosted,
    required this.lecturerName,
    required this.commentsCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      body: json['body'] ?? 'No content',
      datePosted: json['date_posted'] ?? '',
      lecturerName: json['lecturer_name'] ?? 'Unknown Lecturer',
      commentsCount: json['comments_count'] ?? 0,
    );
  }
}

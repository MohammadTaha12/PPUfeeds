class User {
  final String status;
  final String sessionToken;
  final int userId;
  final String username;

  User({
    required this.userId,
    required this.username,
    required this.sessionToken,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      status: json['status'],
      sessionToken: json['session_token'],
      username: json['username'],
      userId: int.parse(json[
          'user_id']), // التحقق من نوع userId وتحويله إلى int إذا لزم الأمر
    );
  }
}

class User {
  final String email;
  final String username;
  final String sessionToken;

  User({
    required this.email,
    required this.username,
    required this.sessionToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      sessionToken: json['session_token'] ?? '',
    );
  }
}

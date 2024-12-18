import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/classes/user.dart';

class LoginViewModel {
  final String loginUrl = "http://feeds.ppu.edu/api/login";

  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Please enter both email and password.");
    }

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        dynamic jsonObject = jsonDecode(response.body);
        if (jsonObject['status'] == 'success') {
          // إنشاء كائن المستخدم
          User user = User(
            email: email,
            username: jsonObject['username'],
            sessionToken: jsonObject['session_token'],
          );

          // تخزين التوكن في SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', user.sessionToken);

          return null; // نجاح عملية تسجيل الدخول
        } else {
          throw Exception("Login failed. Please check your credentials.");
        }
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }
}

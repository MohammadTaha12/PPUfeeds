import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/classes/user.dart';

class LoginViewModel {
  // رابط تسجيل الدخول
  final String loginUrl = "http://feeds.ppu.edu/api/login";

  // دالة تسجيل الدخول
  Future<User?> login(String email, String password) async {
    // التحقق من أن الحقول ليست فارغة
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Please enter both email and password.");
    }

    try {
      // إرسال الطلب إلى الـ API
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      // التحقق من حالة الاستجابة
      switch (response.statusCode) {
        case 200:
          final Map<String, dynamic> jsonObject = jsonDecode(response.body);

          // التحقق من حالة الرد في JSON
          if (jsonObject['status'] == 'success') {
            // إنشاء كائن User باستخدام البيانات
            User user = User.fromJson({
              'status': jsonObject['status'],
              'session_token': jsonObject['session_token'],
              'username': jsonObject['username'],
              'user_id':
                  jsonObject['user_id'].toString(), // تحويل user_id إلى String
            });

            // تخزين التوكن في SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', user.sessionToken);

            return user; // إرجاع كائن المستخدم عند النجاح
          } else {
            throw Exception("Login failed. Please check your credentials.");
          }
        case 400:
          throw Exception("Bad Request: Invalid or malformed request.");
        case 401:
          throw Exception(
              "Unauthorized: Invalid or expired token, or missing token.");
        case 404:
          throw Exception("Not Found: The requested resource does not exist.");
        default:
          throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      // التعامل مع الأخطاء
      throw Exception("An error occurred: $e");
    }
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/course.dart';

class HomeViewModel {
  List<Course> subscribedCourses = [];

  // جلب التوكن
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception("No valid token found. Please log in again.");
    }
    return token;
  }

  // جلب الشعب المشتركة
  Future<List<Course>> fetchSubscribedCourses() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse("http://feeds.ppu.edu/api/v1/subscriptions"),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody != null && responseBody['subscriptions'] != null) {
          final data = responseBody['subscriptions'] as List;

          // تحويل البيانات إلى قائمة كورسات
          subscribedCourses = data.map((item) {
            return Course(
              id: item['section_id'] ?? 0,
              name: item['course'] ?? "No Name",
              college: item['section'] ?? "No Section",
              collegeId: item['id'] ?? 0,
            );
          }).toList();
        }
      } else {
        throw Exception(
            "Failed to fetch subscriptions. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching subscriptions: $e");
    }
    return subscribedCourses;
  }

  // إلغاء الاشتراك من الشعبة
  Future<void> toggleSubscription(int courseId, int sectionId) async {
    final token = await _getToken();
    final url =
        "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/subscribe/$sectionId";

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        print("Successfully unsubscribed from section $sectionId");
      } else {
        throw Exception(
            "Failed to unsubscribe. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error while unsubscribing: $e");
    }
  }
}

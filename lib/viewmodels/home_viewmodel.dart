import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/subscription.dart';

class HomeViewModel {
  List<Subscription> subscriptions = [];

  // جلب التوكن من SharedPreferences
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      throw Exception("No valid token found. Please log in again.");
    }
    return token;
  }

  // جلب الاشتراكات المشتركة
  Future<List<Subscription>> fetchSubscribedSections() async {
    final token = await getToken();
    try {
      final response = await http.get(
        Uri.parse("http://feeds.ppu.edu/api/v1/subscriptions"),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody != null && responseBody['subscriptions'] != null) {
          final data = responseBody['subscriptions'] as List;

          // تحويل البيانات إلى قائمة اشتراكات
          subscriptions = data.map((item) {
            return Subscription.fromJson(item);
          }).toList();
        }
      } else {
        throw Exception(
            "Failed to fetch subscriptions. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching subscriptions: $e");
    }
    return subscriptions;
  }

  // إلغاء الاشتراك من شعبة
  Future<void> unsubscribeSection(
      int courseId, int sectionId, int subscriptionId) async {
    final token = await getToken();
    final url =
        "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/subscribe/$subscriptionId";

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        print("Successfully unsubscribed from subscription $subscriptionId");
      } else {
        throw Exception(
            "Failed to unsubscribe. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error while unsubscribing: $e");
    }
  }

  // البحث عن تفاصيل الكورس باستخدام اسم الكورس
  Future<Map<String, dynamic>> getCourseDetailsByName(String courseName) async {
    try {
      final token = await getToken();

      // جلب جميع الكورسات
      final response = await http.get(
        Uri.parse("http://feeds.ppu.edu/api/v1/courses"),
        headers: {'Authorization': token},
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch courses");
      }

      final coursesData = json.decode(response.body);

      if (coursesData['courses'] == null) {
        throw Exception("Courses not found");
      }

      // البحث عن الكورس باستخدام الاسم
      final course = (coursesData['courses'] as List).firstWhere(
        (c) => c['name'] == courseName,
        orElse: () => null,
      );

      if (course == null) {
        throw Exception("Course with name $courseName not found");
      }

      // جمع البيانات المطلوبة
      final int courseId = course['id'];
      final String collegeName = course['college'];

      return {
        "course_id": courseId,
        "college_name": collegeName,
      };
    } catch (e) {
      throw Exception("Error fetching course by name: $e");
    }
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/course.dart';
import '../classes/section.dart';

class CoursesViewModel {
  List<Course> courses = [];
  Map<int, List<Section>> sections = {};
  Map<int, int> subscriptions = {}; // تخزين subscription_id لكل قسم
  bool isLoading = true;

  // جلب التوكن
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // جلب الكورسات
  Future<List<Course>> fetchCourses() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse("http://feeds.ppu.edu/api/v1/courses"),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['courses'] as List;
        courses = data.map((json) => Course.fromJson(json)).toList();
      }
    } catch (e) {
      throw Exception("Error fetching courses: $e");
    }
    return courses;
  }

  // جلب الأقسام لكل كورس
  Future<void> fetchSections(int courseId) async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse("http://feeds.ppu.edu/api/v1/courses/$courseId/sections"),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['sections'] as List;
        sections[courseId] =
            data.map((json) => Section.fromJson(json)).toList();
      }
    } catch (e) {
      throw Exception("Error fetching sections: $e");
    }
  }

  // جلب الاشتراكات
  Future<void> fetchSubscribedSections() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse("http://feeds.ppu.edu/api/v1/subscriptions"),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['subscriptions'] as List;
        for (var item in data) {
          subscriptions[item['section_id']] = item['id'];
        }
      }
    } catch (e) {
      throw Exception("Error fetching subscriptions: $e");
    }
  }

  // الاشتراك أو إلغاء الاشتراك
  Future<void> toggleSubscription(int courseId, int sectionId) async {
    final token = await _getToken();
    final isSubscribed = subscriptions.containsKey(sectionId);

    if (isSubscribed) {
      // إلغاء الاشتراك
      final subscriptionId = subscriptions[sectionId]!;
      final url =
          "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/subscribe/$subscriptionId";

      try {
        final response = await http
            .delete(Uri.parse(url), headers: {'Authorization': token});

        if (response.statusCode == 200) {
          subscriptions.remove(sectionId); // إزالة من القائمة
        } else {
          throw Exception("Failed to unsubscribe from section $sectionId.");
        }
      } catch (e) {
        throw Exception("Error while unsubscribing: $e");
      }
    } else {
      // الاشتراك
      final url =
          "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/subscribe";

      try {
        final response =
            await http.post(Uri.parse(url), headers: {'Authorization': token});

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          subscriptions[sectionId] =
              data['subscription_id']; // حفظ subscription_id
        } else {
          throw Exception("Failed to subscribe to section $sectionId.");
        }
      } catch (e) {
        throw Exception("Error while subscribing: $e");
      }
    }
  }
}

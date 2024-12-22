import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '/classes/post.dart';

class CoursePostsViewModel {
  final int courseId;
  final int sectionId;

  CoursePostsViewModel({required this.courseId, required this.sectionId});

  // جلب التوكن من SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // جلب جميع المنشورات الخاصة بالدورة والشعبة
  Future<List<Post>> fetchPosts() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
            "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts"),
        headers: {'Authorization': token ?? ''},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['posts'] as List;
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load posts.");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  // جلب تفاصيل منشور معين
  Future<Post> fetchPostDetails(int postId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
            "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId"),
        headers: {'Authorization': token ?? ''},
      );

      if (response.statusCode == 200) {
        final postJson = json.decode(response.body)['post'];
        return Post.fromJson(postJson);
      } else {
        throw Exception("Failed to fetch post details.");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  // إضافة منشور جديد
  Future<int> addPost(String postContent) async {
    if (postContent.isEmpty) {
      throw Exception("Post content cannot be empty.");
    }

    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(
            "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts"),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'body': postContent}),
      );

      if (response.statusCode == 200) {
        final postId = json.decode(response.body)['post_id'];
        return postId;
      } else {
        throw Exception("Failed to add post.");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  // تحديث منشور موجود
  Future<String> updatePost(int postId, String updatedContent) async {
    if (updatedContent.isEmpty) {
      throw Exception("Updated content cannot be empty.");
    }

    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse(
            "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId"),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'body': updatedContent}),
      );

      if (response.statusCode == 200) {
        final status = json.decode(response.body)['status'];
        return status;
      } else {
        throw Exception("Failed to update post.");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }

  // جلب التعليقات لمنشور معين
  Future<int> fetchCommentsCount(int postId) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(
            "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments"),
        headers: {'Authorization': token ?? ''},
      );

      if (response.statusCode == 200) {
        final comments = json.decode(response.body)['comments'] as List;
        return comments.length; // عدد التعليقات
      } else {
        throw Exception("Failed to fetch comments.");
      }
    } catch (e) {
      throw Exception("An error occurred while fetching comments: $e");
    }
  }
}

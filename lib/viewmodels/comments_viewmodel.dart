import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '/classes/comment.dart';

class CommentsViewModel extends ChangeNotifier {
  List<Comment> _comments = [];

  List<Comment> get comments => _comments;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchComments(int courseId, int sectionId, int postId) async {
    final token = await _getToken();
    final url =
        "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments";

    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': token ?? ''});
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['comments'] as List;

        // تحديث التعليقات مع حالة الإعجاب وعدد الإعجابات
        _comments = await Future.wait(data.map((commentJson) async {
          final comment = Comment.fromJson(commentJson);

          // جلب حالة الإعجاب
          final likeStatusUrl =
              "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/${comment.id}/like";
          final likeStatusResponse = await http.get(Uri.parse(likeStatusUrl),
              headers: {'Authorization': token ?? ''});
          if (likeStatusResponse.statusCode == 200) {
            comment.isLiked =
                json.decode(likeStatusResponse.body)['liked'] as bool;
          }

          // جلب عدد الإعجابات
          final likesCountUrl =
              "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/${comment.id}/likes";
          final likesCountResponse = await http.get(Uri.parse(likesCountUrl),
              headers: {'Authorization': token ?? ''});
          if (likesCountResponse.statusCode == 200) {
            comment.likesCount =
                json.decode(likesCountResponse.body)['likes_count'] as int;
          }

          return comment;
        }).toList());

        notifyListeners(); // تحديث واجهة المستخدم
      } else {
        throw Exception("Failed to load comments.");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<void> toggleLike(
      int courseId, int sectionId, int postId, Comment comment) async {
    final token = await _getToken();
    final likeUrl =
        "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/${comment.id}/like";

    try {
      final response = await http
          .post(Uri.parse(likeUrl), headers: {'Authorization': token ?? ''});

      if (response.statusCode == 200) {
        comment.isLiked = !comment.isLiked;
        comment.likesCount += comment.isLiked ? 1 : -1;
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Failed to toggle like: $e");
    }
  }

  Future<void> addComment(
      int courseId, int sectionId, int postId, String commentText) async {
    final token = await _getToken();

    if (commentText.isEmpty) return;

    final url =
        "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'body': commentText}),
      );

      if (response.statusCode == 201) {
        final newComment = Comment.fromJson(json.decode(response.body));
        _comments.add(newComment);
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Failed to add comment: $e");
    }
  }

  Future<void> editComment(int courseId, int sectionId, int postId,
      int commentId, String text) async {
    final token = await _getToken();

    if (text.isEmpty) return;

    final url =
        "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId";

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'body': text}),
      );

      if (response.statusCode == 200) {
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          _comments[index].body = text;
          notifyListeners();
        }
      }
    } catch (e) {
      throw Exception("Failed to edit comment: $e");
    }
  }

  Future<void> deleteComment(
      int courseId, int sectionId, int postId, int commentId) async {
    final token = await _getToken();

    final url =
        "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/$commentId";

    try {
      final response = await http
          .delete(Uri.parse(url), headers: {'Authorization': token ?? ''});

      if (response.statusCode == 200) {
        _comments.removeWhere((c) => c.id == commentId);
        notifyListeners();
      }
    } catch (e) {
      throw Exception("Failed to delete comment: $e");
    }
  }
}

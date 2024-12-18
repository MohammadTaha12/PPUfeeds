import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/comment.dart';

class CommentsViewModel {
  final StreamController<List<Comment>> _commentsController =
      StreamController<List<Comment>>();
  Stream<List<Comment>> get commentsStream => _commentsController.stream;
  List<Comment> _comments = [];

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

        List<Comment> fetchedComments = [];
        for (var commentJson in data) {
          final likesUrl =
              "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/${commentJson['id']}/likes";
          final likedUrl =
              "http://feeds.ppu.edu/api/v1/courses/$courseId/sections/$sectionId/posts/$postId/comments/${commentJson['id']}/like";

          final likesResponse = await http.get(
            Uri.parse(likesUrl),
            headers: {'Authorization': token ?? ''},
          );

          final likedResponse = await http.get(
            Uri.parse(likedUrl),
            headers: {'Authorization': token ?? ''},
          );

          commentJson['likes_count'] = likesResponse.statusCode == 200
              ? json.decode(likesResponse.body)['likes_count']
              : 0;
          commentJson['liked'] = likedResponse.statusCode == 200
              ? json.decode(likedResponse.body)['liked']
              : false;

          fetchedComments.add(Comment.fromJson(commentJson));
        }

        _comments = fetchedComments;
        _commentsController.add(_comments);
      } else {
        _commentsController.addError("Failed to load comments.");
      }
    } catch (e) {
      _commentsController.addError("Error: $e");
    }
  }

  Future<void> toggleLike(dynamic widget, Comment comment) async {
    final token = await _getToken();
    final likeUrl =
        "http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/${comment.id}/like";
    final likesUrl =
        "http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/${comment.id}/likes";

    try {
      await http
          .post(Uri.parse(likeUrl), headers: {'Authorization': token ?? ''});

      final likesResponse = await http.get(
        Uri.parse(likesUrl),
        headers: {'Authorization': token ?? ''},
      );

      if (likesResponse.statusCode == 200) {
        final newLikesCount = json.decode(likesResponse.body)['likes_count'];
        comment.isLiked = !comment.isLiked;
        comment.likesCount = newLikesCount;

        _commentsController.add(_comments);
      }
    } catch (e) {
      _commentsController.addError("Failed to toggle like: $e");
    }
  }

  Future<void> addComment(dynamic widget, String commentText) async {
    final token = await _getToken();

    if (commentText.isEmpty) return;

    final url =
        "http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments";

    try {
      await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'body': commentText}),
      );

      fetchComments(widget.courseId, widget.sectionId, widget.postId);
    } catch (e) {
      _commentsController.addError("Failed to add comment: $e");
    }
  }

  Future<void> editComment(
      dynamic widget, int commentId, String text, Function onSuccess) async {
    final token = await _getToken();

    if (text.isEmpty) return;

    final url =
        "http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId";

    try {
      await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({'body': text}),
      );

      onSuccess();
      fetchComments(widget.courseId, widget.sectionId, widget.postId);
    } catch (e) {
      _commentsController.addError("Failed to edit comment: $e");
    }
  }

  Future<void> deleteComment(dynamic widget, int commentId) async {
    final token = await _getToken();

    final url =
        "http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId";

    try {
      await http
          .delete(Uri.parse(url), headers: {'Authorization': token ?? ''});

      fetchComments(widget.courseId, widget.sectionId, widget.postId);
    } catch (e) {
      _commentsController.addError("Failed to delete comment: $e");
    }
  }

  void dispose() {
    _commentsController.close();
  }
}

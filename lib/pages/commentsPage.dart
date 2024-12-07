// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CommentsScreen extends StatefulWidget {
  final int courseId;
  final int sectionId;
  final int postId;

  CommentsScreen({
    required this.courseId,
    required this.sectionId,
    required this.postId,
  });

  @override
  CommentsScreenState createState() => CommentsScreenState();
}

class CommentsScreenState extends State<CommentsScreen> {
  List<dynamic> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        _showErrorDialog(
            "Authentication token not found. Please log in again.");
        return;
      }

      final response = await http.get(
        Uri.parse(
            "http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments"),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          comments =
              (json.decode(response.body)['comments'] as List).map((comment) {
            comment['liked'] = comment['liked'] ?? false;
            comment['likes_count'] = comment['likes_count'] ?? 0;
            return comment;
          }).toList();
          isLoading = false;
        });
      } else {
        _showErrorDialog("Failed to load comments.");
      }
    } catch (e) {
      _showErrorDialog("An error occurred: $e");
    }
  }

  Future<void> _toggleLike(int commentId, int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        _showErrorDialog(
            "Authentication token not found. Please log in again.");
        return;
      }

      final response = await http.post(
        Uri.parse(
            "http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts/${widget.postId}/comments/$commentId/like"),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          comments[index]['liked'] = !comments[index]['liked'];
          comments[index]['likes_count'] = comments[index]['liked']
              ? comments[index]['likes_count'] + 1
              : comments[index]['likes_count'] - 1;
        });
      } else {
        _showErrorDialog("Failed to toggle like.");
      }
    } catch (e) {
      _showErrorDialog("An error occurred: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : comments.isEmpty
              ? Center(
                  child: Text(
                    "No comments available.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (ctx, index) {
                    final comment = comments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.deepPurpleAccent,
                                    child: Text(
                                      comment['user_name']
                                              ?.substring(0, 1)
                                              ?.toUpperCase() ??
                                          "U",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    comment['user_name'] ?? 'Unknown User',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Spacer(),
                                  Text(
                                    comment['date_posted'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                comment['body'],
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      (comment['liked'] ?? false)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: (comment['liked'] ?? false)
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      _toggleLike(comment['id'], index);
                                    },
                                  ),
                                  Text(
                                    '${comment['likes_count']}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_const_constructors_in_immutables, use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/commentsPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CoursePostsScreen extends StatefulWidget {
  final int courseId;
  final int sectionId;

  CoursePostsScreen({required this.courseId, required this.sectionId});

  @override
  CoursePostsScreenState createState() => CoursePostsScreenState();
}

class CoursePostsScreenState extends State<CoursePostsScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
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
            "http://feeds.ppu.edu/api/v1/courses/${widget.courseId}/sections/${widget.sectionId}/posts"),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          posts = json.decode(response.body)['posts'];
          isLoading = false;
        });
      } else {
        _showErrorDialog("Failed to load posts.");
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
        title: Text("Posts"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? Center(
                  child: Text(
                    "No posts available.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.all(10),
                      elevation: 5,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              post['body'] ?? 'No content',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Posted on: ${post['date_posted']}"),
                          ),
                          OverflowBar(
                            alignment: MainAxisAlignment.start,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommentsScreen(
                                        courseId: widget.courseId,
                                        sectionId: widget.sectionId,
                                        postId: post['id'],
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.comment),
                                label: Text("Comments"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

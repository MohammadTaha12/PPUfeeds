// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'postsPage.dart';

class CoursesPage extends StatefulWidget {
  @override
  CoursesPageState createState() => CoursesPageState();
}

class CoursesPageState extends State<CoursesPage> {
  List<dynamic> courses = [];
  Map<int, List<dynamic>> sections = {};
  Set<int> _expandedCourses = {};
  Set<int> subscribedSections = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final response = await http.get(
        Uri.parse("http://feeds.ppu.edu/api/v1/courses"),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          courses = json.decode(response.body)['courses'];
          isLoading = false;
        });
      } else {
        _showErrorDialog("Failed to load courses.");
      }
    } catch (e) {
      _showErrorDialog("An error occurred: $e");
    }
  }

  Future<void> _fetchSections(int courseId) async {
    if (sections.containsKey(courseId)) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final response = await http.get(
        Uri.parse("http://feeds.ppu.edu/api/v1/courses/$courseId/sections"),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          sections[courseId] = json.decode(response.body)['sections'];
        });
      } else {
        _showErrorDialog("Failed to load sections for course $courseId.");
      }
    } catch (e) {
      _showErrorDialog("An error occurred: $e");
    }
  }

  Future<void> _toggleSubscription(int sectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final isSubscribed = subscribedSections.contains(sectionId);

    try {
      final response = await http.post(
        Uri.parse(
            "http://feeds.ppu.edu/api/v1/sections/$sectionId/${isSubscribed ? 'unsubscribe' : 'subscribe'}"),
        headers: {
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          if (isSubscribed) {
            subscribedSections.remove(sectionId);
          } else {
            subscribedSections.add(sectionId);
          }
        });
      } else {
        _showErrorDialog(
            "Failed to ${isSubscribed ? 'unsubscribe from' : 'subscribe to'} section $sectionId.");
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

  String _getInitials(String courseName) {
    List<String> words = courseName.split(" ");
    if (words.length >= 2) {
      return "${words[0][0]}${words[1][0]}".toUpperCase();
    }
    return courseName.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Courses"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: courses.length,
              padding: EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final course = courses[index];
                final isExpanded = _expandedCourses.contains(course['id']);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurpleAccent,
                          child: Text(
                            _getInitials(course['name']),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          course['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("College: ${course['college']}"),
                        trailing: IconButton(
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedCourses.remove(course['id']);
                              } else {
                                _expandedCourses.add(course['id']);
                                _fetchSections(course['id']);
                              }
                            });
                          },
                        ),
                      ),
                      if (isExpanded)
                        Column(
                          children: (sections[course['id']] ?? [])
                              .map<Widget>((section) {
                            final isSubscribed =
                                subscribedSections.contains(section['id']);
                            return ListTile(
                              leading: Icon(Icons.class_,
                                  color: Colors.deepPurpleAccent),
                              title: Text(
                                "Section: ${section['name']}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  "Lecturer: ${section['lecturer'] ?? 'N/A'}"),
                              trailing: TextButton(
                                onPressed: () {
                                  _toggleSubscription(section['id']);
                                },
                                child: Text(
                                  isSubscribed ? "Unsubscribe" : "Subscribe",
                                  style: TextStyle(
                                      color: isSubscribed
                                          ? Colors.red
                                          : Colors.green),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CoursePostsScreen(
                                      courseId: course['id'],
                                      sectionId: section['id'],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '/viewmodels/home_viewmodel.dart';
import '/classes/subscription.dart';
import 'coursesPage.dart';
import 'postsPage.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final HomeViewModel viewModel = HomeViewModel();
  List<Subscription> subscriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  // جلب بيانات الاشتراكات
  Future<void> fetchSubscriptions() async {
    try {
      final fetchedSubscriptions = await viewModel.fetchSubscribedSections();
      setState(() {
        subscriptions = fetchedSubscriptions.reversed.toList();
        isLoading = false;
      });
    } catch (e) {
      _showErrorDialog("Error fetching subscriptions: $e");
    }
  }

  // دالة لجلب البيانات بناءً على النوع
  Future<dynamic> fetchCourseDetails(String courseName, String type) async {
    try {
      final courseDetails = await viewModel.getCourseDetailsByName(courseName);
      if (type == "course_id") {
        return int.parse(courseDetails['course_id'].toString());
      } else if (type == "college_name") {
        return courseDetails['college_name'];
      } else {
        throw Exception(
            "Invalid type provided. Use 'course_id' or 'college_name'.");
      }
    } catch (e) {
      throw Exception("Error fetching details: $e");
    }
  }

  // إلغاء الاشتراك
  Future<void> _unsubscribe(Subscription subscription) async {
    try {
      await viewModel.unsubscribeSection(
        subscription.id, // subscriptionId
        subscription.sectionId, // sectionId
        fetchCourseDetails(subscription.courseName, "course_id")
            as int, // courseId
      );
      setState(() {
        subscriptions.remove(subscription); // إزالة الشعبة من القائمة
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unsubscribed from ${subscription.courseName}")),
      );
    } catch (e) {
      _showErrorDialog("Error while unsubscribing: $e");
    }
  }

  // عرض رسالة خطأ
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

  // تأكيد الإلغاء
  void _showConfirmationDialog(Subscription subscription) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            "Are you sure you want to unsubscribe ?",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // إغلاق الحوار
                await _unsubscribe(subscription);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Subscribed Sections",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text("Courses"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoursesPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : subscriptions.isEmpty
              ? Center(child: Text("No subscriptions found."))
              : ListView.builder(
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    final subscription = subscriptions[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.redAccent,
                          child: Text(
                            subscription.courseName.isNotEmpty
                                ? subscription.courseName[0]
                                : "C",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(subscription.courseName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Section: ${subscription.sectionName}"),
                            Text("Lecturer: ${subscription.lecturer}"),
                            FutureBuilder(
                              future: fetchCourseDetails(
                                  subscription.courseName, "college_name"),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text("Loading College Name...");
                                } else if (snapshot.hasError) {
                                  return Text("Error: ${snapshot.error}");
                                } else {
                                  return Text("College Name: ${snapshot.data}");
                                }
                              },
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            _showConfirmationDialog(subscription);
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CoursePostsScreen(
                                courseId: subscription.id,
                                sectionId: subscription.sectionId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

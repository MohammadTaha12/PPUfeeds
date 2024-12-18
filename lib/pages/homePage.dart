import 'package:flutter/material.dart';
import 'package:flutter_application_3/pages/coursesPage.dart';
import 'package:flutter_application_3/viewmodels/home_viewmodel.dart';
import '../classes/course.dart';
import 'postsPage.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final HomeViewModel _viewModel = HomeViewModel();
  List<Course> subscribedCourses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubscribedCourses();
  }

  // جلب الشعب المشتركة
  Future<void> _fetchSubscribedCourses() async {
    try {
      final fetchedCourses = await _viewModel.fetchSubscribedCourses();
      setState(() {
        subscribedCourses = fetchedCourses;
        isLoading = false;
      });
    } catch (e) {
      _showErrorDialog("Error fetching subscribed sections: $e");
    }
  }

  // إلغاء الاشتراك
  Future<void> _unsubscribe(int courseId, int sectionId) async {
    try {
      await _viewModel.toggleSubscription(courseId, sectionId);
      setState(() {
        subscribedCourses.removeWhere((course) => course.id == sectionId);
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Subscribed Sections"),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
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
                  MaterialPageRoute(builder: (context) => CoursesPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : subscribedCourses.isEmpty
              ? Center(child: Text("No subscribed sections found."))
              : ListView.builder(
                  itemCount: subscribedCourses.length,
                  itemBuilder: (context, index) {
                    final course = subscribedCourses[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            course.name.isNotEmpty
                                ? course.name[0]
                                : "S", // عرض أول حرف من اسم الشعبة
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(course.name),
                        subtitle: Text("Section: ${course.college}"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () =>
                              _unsubscribe(course.collegeId, course.id),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CoursePostsScreen(
                                courseId: course.collegeId,
                                sectionId: course.id,
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

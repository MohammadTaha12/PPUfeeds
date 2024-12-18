// ignore_for_file: prefer_const_constructors, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import '../viewmodels/courses_viewmodel.dart';
import 'homePage.dart';

class CoursesPage extends StatefulWidget {
  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final CoursesViewModel viewModel = CoursesViewModel();
  bool isLoading = true;
  Set<int> expandedCourses = {}; // لتتبع الكورسات المعروضة

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    await viewModel.fetchSubscribedSections(); // جلب الشعب المشتركة
    await viewModel.fetchCourses(); // جلب جميع الكورسات
    setState(() => isLoading = false);
  }

  void _toggleCourseExpansion(int courseId) async {
    if (expandedCourses.contains(courseId)) {
      // إذا كانت الكورس بالفعل في حالة توسع، قم بإغلاقه
      setState(() {
        expandedCourses.remove(courseId);
      });
    } else {
      // إذا لم تكن موجودة، أضفها وتحقق إذا الشعب تم جلبها
      if (!viewModel.sections.containsKey(courseId)) {
        await viewModel.fetchSections(courseId); // جلب الشعب فقط أول مرة
      }
      setState(() {
        expandedCourses.add(courseId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feeds Screen"),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Center(
                child: Text(
                  "My App",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: viewModel.courses.length,
              itemBuilder: (context, index) {
                final course = viewModel.courses[index];
                final isExpanded = expandedCourses.contains(course.id);
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurpleAccent,
                          child: Text(
                            course.name.substring(0, 2).toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(course.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("College: ${course.college}"),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () => _toggleCourseExpansion(course.id),
                        ),
                      ),
                      if (isExpanded)
                        Column(
                          children: [
                            if (viewModel.sections[course.id] == null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "No sections available for this course.",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              )
                            else if (viewModel.sections[course.id]!.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "No sections available for this course.",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              )
                            else
                              ...viewModel.sections[course.id]!.map((section) {
                                final isSubscribed = viewModel.subscriptions
                                    .containsKey(section.id);
                                return ListTile(
                                  title: Text("Section: ${section.name}"),
                                  subtitle:
                                      Text("Lecturer: ${section.lecturer}"),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSubscribed
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    onPressed: () async {
                                      await viewModel.toggleSubscription(
                                          course.id, section.id);
                                      setState(() {});
                                    },
                                    child: Text(isSubscribed
                                        ? "Unsubscribe"
                                        : "Subscribe"),
                                  ),
                                );
                              }).toList(),
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

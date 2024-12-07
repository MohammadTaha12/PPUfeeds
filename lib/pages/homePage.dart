// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'coursesPage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> subscribedSections = [];

  @override
  void initState() {
    super.initState();
    _fetchSubscribedSections();
  }

  Future<void> _fetchSubscribedSections() async {
    setState(() {
      subscribedSections = [
        {
          "course_name": "Course A",
          "section_name": "Section 1",
          "lecturer": "Dr. Smith"
        },
        {
          "course_name": "Course B",
          "section_name": "Section 2",
          "lecturer": "Dr. Jane"
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
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
              leading: Icon(Icons.school),
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
      body: subscribedSections.isEmpty
          ? Center(child: Text("No subscribed sections."))
          : ListView.builder(
              itemCount: subscribedSections.length,
              itemBuilder: (context, index) {
                final section = subscribedSections[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Icon(Icons.class_, color: Colors.deepPurpleAccent),
                    title: Text(
                      "${section['course_name']} - ${section['section_name']}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Lecturer: ${section['lecturer']}"),
                  ),
                );
              },
            ),
    );
  }
}

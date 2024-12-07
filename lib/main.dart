import 'package:flutter/material.dart';
import 'pages/loginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPU feeds',
      theme: ThemeData(),
      home: LoginPage(),
    );
  }
}

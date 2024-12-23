import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/comments_viewmodel.dart';
import 'pages/loginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommentsViewModel()),
      ],
      child: MaterialApp(
        title: 'PPU feeds',
        theme: ThemeData(),
        home: LoginPage(),
      ),
    );
  }
}

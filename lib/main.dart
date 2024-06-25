import 'package:flutter/material.dart';
import 'package:foot_mobile/pages/first.page.dart';
import 'package:foot_mobile/pages/home.page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application Football',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FirstPage(),
        '/home': (context) => HomePage('Football'),
      },
    );
  }
}

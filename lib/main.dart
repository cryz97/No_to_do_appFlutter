import 'package:flutter/material.dart';
import 'ui/Home.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoToDo',
      home: new Home(),
    );
  }
}


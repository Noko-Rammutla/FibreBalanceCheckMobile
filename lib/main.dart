import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';

void main() => runApp(FibreCheckApp());

class FibreCheckApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fibre Balance Checker',
      home: LoginPage(),
    );
  }
}

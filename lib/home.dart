import 'dart:async';

import 'package:flutter/material.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String password;
  HomePage({Key key, this.username, this.password}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  bool _error = false;
  String _errorMessage = "";
  
  @override
  void initState() {
    Timer(Duration(seconds: 5), GetData);
    super.initState();
  }

  void GetData() {
    setState(() {
     _loading = false;
     _error = true;
     _errorMessage =  "Method not yet implemented, cannot load usage data.";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
    {
      return _buildLoadingScreen(context);
    }
    else
    {
      return _buildErrorScreen(context);
    }
  }

  Widget _buildLoadingScreen(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ),
    );
  }
}
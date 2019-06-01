import 'package:fibre_balance_check/home.dart';
import 'package:fibre_balance_check/webafrica.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _error = false;
  bool _loggingIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Text('Fibre/LTE Balance Check'),
                SizedBox(height: 80),
                Text('WebAfrica Only', style: TextStyle(color: Colors.red))
              ],
            ),
            SizedBox(height: 120.0),
            TextField(
              decoration: InputDecoration(
                filled: true,
                labelText: 'Username',
              ),
              controller: _usernameController,
            ),
            SizedBox(height: 12.0),
            TextField(
              decoration: InputDecoration(
                filled: true,
                labelText: 'Password',
              ),
              obscureText: true,
              controller: _passwordController,
            ),
            ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text('CANCEL'),
                  onPressed: () {
                    _usernameController.clear();
                    _passwordController.clear();
                  },
                ),
                RaisedButton(
                  child: Text('NEXT'),
                  onPressed: _loggingIn ? null : attempLogin,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 48.0),
              child: Center(
                child: Text(_error ? "Login Failed" : "",
                    style: TextStyle(color: Colors.red)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void attempLogin() {
    setState(() {
      _error = false;
      _loggingIn = true;
    });
    WebAfricaUsage webAfricaUsage = WebAfricaUsage();
    webAfricaUsage
        .login(_usernameController.text, _passwordController.text)
        .then((bool value) {
      if (value == true) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      webAfricaUsage: webAfricaUsage,
                    )));
        setState(() {
          _error = false;
          _loggingIn = false;
        });
      } else {
        setState(() {
          _error = true;
          _loggingIn = false;
        });
      }
    });
  }
}

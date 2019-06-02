import 'package:fibre_balance_check/home.dart';
import 'package:fibre_balance_check/providers/providers.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _providers = <BaseProvider>[WebAfricaUsage(), MockUsage(usageDelay: Duration(seconds: 1))];
  BaseProvider _provider;

  bool _error = false;
  bool _loggingIn = false;

  @override
  initState() {
    super.initState();
    setState(() {
    _provider = _providers[0]; 
    });
  }

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
                Text('Fibre/LTE Balance Check', style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                )),
                SizedBox(height: 40),
                Text('WebAfrica only', style: TextStyle(color: Colors.red)),
                SizedBox(height: 160),
                Text('Select Internet Provider'),
                DropdownButton(
                  value: _provider,
                  isExpanded: true,
                  items: getDropDownItems(),
                  onChanged: (value) {
                    setState(() {
                     _provider = value; 
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20.0),
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

  List<DropdownMenuItem<BaseProvider>> getDropDownItems() {
    var list = List<DropdownMenuItem<BaseProvider>>();
    for (var provider in _providers) {
      list.add(
        DropdownMenuItem<BaseProvider>(
          child: Center(child: Text(provider.getName())),
          value: provider,
        )
      );
    }
    return list;
  }

  void attempLogin() {
    setState(() {
      _error = false;
      _loggingIn = true;
    });
    _provider
        .login(_usernameController.text, _passwordController.text)
        .then((bool value) {
      if (value == true) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      usageProvider: _provider,
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

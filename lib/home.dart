import 'dart:async';

import 'package:flutter/material.dart';
import 'workers.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String password;
  HomePage({Key key, this.username, this.password}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(username: username, password: password);
}

class _HomePageState extends State<HomePage> {
  bool _loading = true;
  bool _error = false;
  String _errorMessage = "";
  List<Map<String, String>> _products;

  final String username;
  final String password;
  _HomePageState({this.username, this.password});
  
  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    DummyChecker webAfricaChecker = DummyChecker();
    String login = await webAfricaChecker.login(username, password);
    
    if (login != "")
    {
      setState(() {
          _loading = false;
          _error = true;
          _errorMessage =  login;
          });
        return;
    }

    List<String> products = await webAfricaChecker.getProductList();
    _products = List<Map<String, String>>();

    for (var productId in products) {
      var result = await webAfricaChecker.getProduct(productId);
      _products.insert(_products.length, result);
    }
    setState(() {
     _loading = false;
     _error = false; 
    });
  }


  String _getFriendlyName(String id, String defaultName) {
    return defaultName;
  }    

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoadingScreen(context);
    }
    else if (_error) {
      return _buildErrorScreen(context);
    }
    else {
      return _buildBalanceScreen(context);
    }
  }

  Widget _buildItem(Map<String, String> product) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Colors.black,
          ),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Column(
          children: <Widget>[
            Text(
              _getFriendlyName(product["id"], product["packageName"]),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(product["usage"], style: TextStyle(color: Colors.blueGrey)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: <Widget>[
                  Text("updated: "),
                  Text(product["lastUpdate"]),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildBalanceScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Balances"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: _products.map(_buildItem).toList(),
      ),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text('Loading...'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text('Error'),
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
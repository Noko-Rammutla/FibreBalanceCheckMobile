import 'dart:async';

import 'package:fibre_balance_check/usage.dart';
import 'package:flutter/material.dart';
import 'webafrica.dart';

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
  List<Usage> _products = List<Usage>();

  final String username;
  final String password;
  _HomePageState({this.username, this.password});
  
  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    WebAfricaUsage webAfricaUsage = WebAfricaUsage();
    
    bool loggedIn = await webAfricaUsage.login(username, password);
    if (loggedIn == false)
    {
      setState(() {
          _loading = false;
          _error = true;
          _errorMessage = "Login Failed";
          });
        return;
    }

    setState(() {
     _loading = true;
     _error = false; 
    });

    for (var productId in await webAfricaUsage.getProductList()) {
      var usage = await webAfricaUsage.getUsage(productId);
      setState(() {
       _products.add(usage); 
      });
    }

    setState(() {
     _loading = false;
    });
  }


  String _getFriendlyName(String id, String defaultName) {
    return defaultName;
  }    

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return _buildErrorScreen(context);
    }
    else {
      return _buildBalanceScreen(context);
    }
  }

  Widget _buildItem(Usage product) {
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
              _getFriendlyName(product.id, product.packageName),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(product.usage, style: TextStyle(color: Colors.blueGrey)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: <Widget>[
                  Text("updated: "),
                  Text(product.lastUpdate),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildBalanceScreen(BuildContext context) {
    var widgetList = _products.map(_buildItem).toList();
    if (_loading) {
      widgetList.add(_buildLoadingIndicator(context));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Balances"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: widgetList,
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
     return Padding(
       padding: const EdgeInsets.all(32.0),
       child: Center(
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
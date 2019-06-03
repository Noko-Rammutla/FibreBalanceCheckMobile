import 'package:fibre_balance_check/common/usage.dart';
import 'package:fibre_balance_check/usage_view.dart';
import 'package:flutter/material.dart';
import 'package:fibre_balance_check/providers/base_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final BaseProvider usageProvider;
  HomePage({Key key, this.usageProvider}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _loading = true;
  List<UsageView> _products = List<UsageView>();
  
  @override
  void initState() {
    
    _loadUsage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return _buildBalanceScreen(context);
  }

  void _handleInsert(Usage usage) {
    UsageView view = UsageView(
      usage: usage,
      animationController: AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      ),
      onRename: _onRename,
      onDelete: _onDelete,
    );
    setState(() {
     _products.insert(0, view); 
    });
    view.animationController.forward();
  }
 
  Widget _buildBalanceScreen(BuildContext context) {
    var widgetList = <Widget>[];
    widgetList.addAll(_products);
    if (_loading) {
      widgetList.add(_buildLoadingIndicator(context));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Balances"),
        backgroundColor: Colors.blueGrey,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _resetUsage,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsage,
          ),
        ],
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

  Future<void> _onRename(Usage usage, String name) async {
    if (name != null && name != "") {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(usage.id, name);
      
      _loadUsage();
    }
  }

  Future<void> _onDelete(Usage usage) async {
    final prefs = await SharedPreferences.getInstance();
    var hidden = prefs.getStringList('hidden');
    if (hidden == null)
      hidden = [];
    if (hidden.indexOf(usage.id) == -1) {
      hidden.add(usage.id);
      prefs.setStringList('hidden', hidden);
    }

    int index = -1;
     for (int i = 0; i < _products.length; i++) {
       if (_products[i].usage.id == usage.id) {
         index = i;
         break;
       }
     }

    setState(() {
     if (index != -1) {
       _products.removeAt(index);
     }
    });
  }

  Future<void> _resetUsage() async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in prefs.getKeys()) {
      prefs.remove(key);
    }
    await _loadUsage();
  }

  Future<void> _loadUsage() async {
    setState(() {
     _loading = true;
     _products.clear();
    });

    final prefs = await SharedPreferences.getInstance();
    var hidden = prefs.getStringList('hidden');
    if (hidden == null)
      hidden = [];

    var productList  = await widget.usageProvider.getProductList();
    for (var productId in productList.reversed) {
      if (hidden.indexOf(productId) ==  -1) {
        var usage = await widget.usageProvider.getUsage(productId);
        var friendlyName = prefs.getString(productId);
        if (friendlyName != null) {
          usage.packageName = friendlyName;
        }
        _handleInsert(usage);
      }
    }

    setState(() {
     _loading = false; 
    });
  }

  @override
  void dispose() {
    for (var view in _products)
      view.animationController.dispose();
    super.dispose();
  }  
}
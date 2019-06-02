import 'package:fibre_balance_check/common/usage.dart';
import 'package:fibre_balance_check/usage_view.dart';
import 'package:flutter/material.dart';
import 'package:fibre_balance_check/providers/base_provider.dart';

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
    getData();
    super.initState();
  }

  void getData() async {
    var productList  = await widget.usageProvider.getProductList();
    for (var productId in productList.reversed) {
      var usage = await widget.usageProvider.getUsage(productId);
      _handleInsert(usage);
    }

    setState(() {
     _loading = false;
    });
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

  @override
  void dispose() {
    for (var view in _products)
      view.animationController.dispose();
    super.dispose();
  }  
}
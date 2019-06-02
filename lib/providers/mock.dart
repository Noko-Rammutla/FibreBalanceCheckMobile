import 'dart:math';

import 'package:fibre_balance_check/providers/base_provider.dart';
import 'package:fibre_balance_check/common/usage.dart';
import 'package:intl/intl.dart';

class MockUsage implements BaseProvider{
  Duration productListDelay;
  Duration usageDelay;
  Duration loginDelay;

  MockUsage({this.productListDelay, this.usageDelay, this.loginDelay});

  @override
  Future<List<String>> getProductList() async {
    var result = ['a', 'b', 'c'];
    if (productListDelay == null)
      return result;
    else
      return Future.delayed(productListDelay, () => result);
  }

  @override
  Future<Usage> getUsage(String productId) async {
    var randomGen = Random();
    var time = DateTime.now();
    time = time.add(Duration(hours: -randomGen.nextInt(3), minutes: randomGen.nextInt(59)));
    var lastUpdate = "${DateFormat('d MMMM y').format(time)} at ${DateFormat('jm').format(time)}";
    Usage result;
    switch (productId) {
      case 'a':
        result = Usage(
          id: 'a',
          packageName: 'Fibre 50 GB',
          lastUpdate: 'Last updated: $lastUpdate',
          usage: '4.70 GB of 50 GB',
        );
        break;
      case 'b':
        result = Usage(
          id: 'b',
          packageName: 'LTE 100 GB',
          lastUpdate: 'Last updated: $lastUpdate',
          usage: '43.62 GB of 50 GB',
        );
        break;
      case 'c': 
        result = Usage(
          id: 'c',
          packageName: 'Fibre 50 GB',
          lastUpdate: 'Last updated: $lastUpdate',
          usage: '0.70 GB of 50 GB',
        );
        break;
      default:
        result = null;
    }
    if (usageDelay == null)
      return result;
    else
      return Future.delayed(usageDelay, () => result);
  }

  @override
  Future<bool> login(String username, String password) async {
    if (loginDelay == null)
      return true;
    else
      return Future.delayed(loginDelay, () => true);
  }

  @override
  String getName() {
    return "Demo Usage";
  }

}
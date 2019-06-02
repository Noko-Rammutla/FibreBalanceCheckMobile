import 'dart:io';

import 'package:fibre_balance_check/providers/base_provider.dart';
import 'package:fibre_balance_check/common/usage.dart';

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
    Usage result;
    switch (productId) {
      case 'a':
        result = Usage(
          id: 'a',
          packageName: 'Fibre 50 GB',
          lastUpdate: 'Last updated: 2nd June 2019 at 3:01 PM',
          usage: '4.70 GB of 50 GB',
        );
        break;
      case 'b':
        result = Usage(
          id: 'b',
          packageName: 'LTE 100 GB',
          lastUpdate: 'Last updated: 2nd June 2019 at 2:01 PM',
          usage: '43.62 GB of 50 GB',
        );
        break;
      case 'c': 
        result = Usage(
          id: 'c',
          packageName: 'Fibre 50 GB',
          lastUpdate: 'Last updated: 2nd June 2019 at 3:03 PM',
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
    return "Name";
  }

}
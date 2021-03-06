import 'dart:io';
import 'dart:convert';

import 'package:fibre_balance_check/common/html_utils.dart';
import 'package:fibre_balance_check/providers/base_provider.dart';
import 'package:fibre_balance_check/common/usage.dart';

List<String> productList(String productsPage) {
  List<String> results = List<String>();

  RegExp exp = RegExp(r'\<a.*>');
  for (var match in exp.allMatches(productsPage)) {
    String link = productsPage.substring(match.start, match.end);
    if (link.contains('LoginToDSLConsole')) {
      String id = RegExp(r'id=\d+').stringMatch(link);
      if (id != null) {
        results.add(id.substring(3));
      }
    }
  }

  return results;
}

double _getUnits(String units) {
  switch (units.toLowerCase()) {
    case "mb":
      return 1e-3;
    default:
      return 1;
  }
}

List<double> getAmounts(String usage) {
  var searchStr = usage.replaceAll(',', '.');
  var numbersExp = RegExp(r'([0-9]+\.?[0-9]*)\ (\w*)');
  var numberList = <double>[];
  for (var num in numbersExp.allMatches(searchStr)) {
    var digits = num.group(1);
    var units = num.group(2);
    numberList.add(double.parse(digits) * _getUnits(units));
  }
  return numberList;
}

Usage getProduct(String productPage, String productId) {
  var result = Usage(
    id: productId,
    packageName: getInput(productPage, 'data-role', 'packageName'),
    lastUpdate: getSpan(productPage,
        'ctl00_ctl00_contentDefault_contentControlPanel_lbllastUpdted'),
    usage: 0,
    total: 0,
  );
  var lteUsage = getSpan(productPage,
      'ctl00_ctl00_contentDefault_contentControlPanel_lblAnytimeCap');
  var usageList = getAmounts(lteUsage);
  if (usageList.length == 2) {
    result.usage += usageList[0];
    result.total += usageList[1];
    lteUsage = getSpan(productPage,
        'ctl00_ctl00_contentDefault_contentControlPanel_lblCalendarTopupCap');
    usageList = getAmounts(lteUsage);
    if (usageList.length == 2) {
      result.usage += usageList[0];
      result.total += usageList[1];
    }
  }

  return result;
}

class WebAfricaUsage implements BaseProvider {
  final String urlHome = "https://www.webafrica.co.za/clientarea.php";
  final String urlLogin = "https://www.webafrica.co.za/dologin.php";
  final String urlProducts =
      "https://www.webafrica.co.za/myservices.php?pagetype=adsl";
  final String urlProduct =
      "https://www.webafrica.co.za/clientarea.php?action=productdetails&id={productId}&modop=custom&a=LoginToDSLConsole";
  final String urlUsage = "https://usage.webafrica.co.za/usage.html";
  final String urlFibre =
      "https://www.webafrica.co.za/includes/fup.handler.php?cmd=getfupinfo&username=";

  List<Cookie> _cookies = List<Cookie>();
  HttpClient _client = new HttpClient();

  @override
  Future<bool> login(String username, String password) async {
    var request = await _client.getUrl(Uri.parse(urlHome));
    var response = await request.close();

    _cookies = response.cookies;
    Stream<String> stream = response.transform(utf8.decoder);
    String body = await stream.join();

    String token = getInput(body, "name", "token");
    request = await _client.postUrl(Uri.parse(urlLogin));
    request.headers.set('content-type', 'application/x-www-form-urlencoded');
    request.cookies.addAll(_cookies);
    body =
        'token=${Uri.encodeQueryComponent(token)}&username=${Uri.encodeQueryComponent(username)}&password=${Uri.encodeQueryComponent(password)}';
    request.add(utf8.encode(body));

    response = await request.close();
    bool success = false;
    response.headers.forEach((String name, List<String> values) {
      if (name == 'location' && values[0] == "/clientarea.php") success = true;
    });

    return success;
  }

  @override
  Future<List<String>> getProductList() async {
    var request = await _client.getUrl(Uri.parse(urlProducts));
    request.cookies.addAll(_cookies);
    var response = await request.close();
    var stream = response.transform(utf8.decoder);
    var body = await stream.join();

    return productList(body);
  }

  @override
  Future<Usage> getUsage(String productId) async {
    String url = urlProduct.replaceAll(RegExp("{productId}"), productId);

    var request = await _client.getUrl(Uri.parse(url));
    request.followRedirects = false;
    request.cookies.addAll(_cookies);
    var response = await request.close();
    await response.transform(utf8.decoder).join();
    response = await response.redirect();

    List<Cookie> usageCookies = response.cookies;
    request = await _client.getUrl(Uri.parse(urlUsage));
    request.cookies.add(_cookies[0]);
    request.cookies.add(usageCookies[0]);
    request.cookies.add(usageCookies[4]);
    request.cookies.add(usageCookies[5]);
    request.cookies.add(usageCookies[6]);
    response = await request.close();

    var stream = response.transform(utf8.decoder);
    var body = await stream.join();

    var results = getProduct(body, productId);
    if (results.total == 0) {
      String username = getInput(body, 'data-role', 'userName');
      request = await _client
          .getUrl(Uri.parse(urlFibre + Uri.encodeQueryComponent(username)));
      response = await request.close();

      Stream<String> stream = response.transform(utf8.decoder);
      body = await stream.join();
      var map = json.decode(body);
      results.usage = map['Data']['Usage'] / 1024 / 1024 / 1024;
      results.total = map['Data']['Threshold'] / 1024 / 1024 / 1024;
    }
    return results;
  }

  @override
  String getName() {
    return 'WebAfrica';
  }
}

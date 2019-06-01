import 'dart:io';
import 'dart:convert';

import 'package:fibre_balance_check/usage.dart';

String _getInput(String page, String attrib, String value) {
  RegExp exp = new RegExp(r"\<input.*/>", multiLine: true);
  for (var match in exp.allMatches(page)) {
    String link = page.substring(match.start, match.end);
    if (link.contains(attrib + '="' + value + '"')) {
      exp = new RegExp(r'value=".*?"', multiLine: true);
      value = exp.stringMatch(link);
      if (value == null) return "";
      return value.substring(7, value.length - 1);
    }
  }
  return "";
}

String _getSpan(String page, String spanId) {
  RegExp exp = new RegExp(r'\<span.*?\</span>', multiLine: true);
  for (var match in exp.allMatches(page)) {
    String span = page.substring(match.start, match.end);
    if (span.contains('id="' + spanId + '"')) {
      String text =
          span.substring(span.indexOf(RegExp(r'>')) + 1, span.length - 7);
      text = text.replaceAll(RegExp(r'\<b>'), '');
      text = text.replaceAll(RegExp(r'\</b>'), '');
      return text;
    }
  }
  return "";
}

String loginToken(String homePage) {
  return _getInput(homePage, "name", "token");
}

List<String> productList(String productsPage) {
  List<String> results = List<String>();

  RegExp exp = RegExp(r'\<a.*>');
  for (var match in exp.allMatches(productsPage)) {
    String link = productsPage.substring(match.start, match.end);
    if (link.contains('LoginToDSLConsole')) {
      String id = RegExp(r'id=\d+').stringMatch(link);
      if (id != null) {
        results.add(id);
      }
    }
  }

  return results;
}

Usage getProduct(String productPage, String productId) {
  var result = Usage(
    id: productId.substring(3),
    packageName: _getInput(productPage, 'data-role', 'packageName'),
    lastUpdate: _getSpan(productPage,
        'ctl00_ctl00_contentDefault_contentControlPanel_lbllastUpdted'),
  );
  var lteUsage = _getSpan(productPage,
      'ctl00_ctl00_contentDefault_contentControlPanel_lblAnytimeCap');
  if (lteUsage != '') result.usage = lteUsage;
  return result;
}

class WebAfricaUsage {
  final String urlHome = "https://www.webafrica.co.za/clientarea.php";
  final String urlLogin = "https://www.webafrica.co.za/dologin.php";
  final String urlProducts =
      "https://www.webafrica.co.za/myservices.php?pagetype=adsl";
  final String urlProduct =
      "https://www.webafrica.co.za/clientarea.php?action=productdetails&{productId}&modop=custom&a=LoginToDSLConsole";
  final String urlUsage = "https://usage.webafrica.co.za/usage.html";
  final String urlFibre =
      "https://www.webafrica.co.za/includes/fup.handler.php?cmd=getfupinfo&username=";

  List<Cookie> _cookies = List<Cookie>();
  HttpClient _client = new HttpClient();

  Future<bool> login(String username, String password) async {
    var request = await _client.getUrl(Uri.parse(urlHome));
    var response = await request.close();

    _cookies = response.cookies;
    Stream<String> stream = response.transform(utf8.decoder);
    String body = await stream.join();

    String token = loginToken(body);
    request = await _client.postUrl(Uri.parse(urlLogin));
    request.headers.set('content-type', 'application/x-www-form-urlencoded');
    request.cookies.addAll(_cookies);
    body =
        'token=${Uri.encodeQueryComponent(token)}&username=${Uri.encodeQueryComponent(username)}&password=${Uri.encodeQueryComponent(password)}';
    request.add(utf8.encode(body));

    response = await request.close();
    bool success = false;
    response.headers.forEach((String name, List<String> values) {
      if (name == 'location' && values[0] == "/clientarea.php")
        success = true;
    });

    return success;
  }

  Future<List<String>> getProductList() async {
    var request = await _client.getUrl(Uri.parse(urlProducts));
    request.cookies.addAll(_cookies);
    var response = await request.close();
    var stream = response.transform(utf8.decoder);
    var body = await stream.join();

    return productList(body);
  }

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
    if (results.usage == null) {
      String username = _getInput(body, 'data-role', 'userName');
      request = await _client
          .getUrl(Uri.parse(urlFibre + Uri.encodeQueryComponent(username)));
      response = await request.close();

      Stream<String> stream = response.transform(utf8.decoder);
      body = await stream.join();
      var map = json.decode(body);
      var usage = map['Data']['Usage'] / 1024 / 1024 / 1024;
      var total = map['Data']['Threshold'] / 1024 / 1024 / 1024;
      results.usage =
          '(${usage.toStringAsFixed(2)} GB of ${total.toStringAsFixed(2)} GB)';
    }
    return results;
  }
}

Future<List<Usage>> getWebAfricaUsage(String username, String password) async {
  final String urlHome = "https://www.webafrica.co.za/clientarea.php";
  final String urlLogin = "https://www.webafrica.co.za/dologin.php";
  final String urlProducts =
      "https://www.webafrica.co.za/myservices.php?pagetype=adsl";
  final String urlProduct =
      "https://www.webafrica.co.za/clientarea.php?action=productdetails&{productId}&modop=custom&a=LoginToDSLConsole";
  final String urlUsage = "https://usage.webafrica.co.za/usage.html";
  final String urlFibre =
      "https://www.webafrica.co.za/includes/fup.handler.php?cmd=getfupinfo&username=";

  HttpClient client = new HttpClient();
  var request = await client.getUrl(Uri.parse(urlHome));
  var response = await request.close();

  List<Cookie> cookies = response.cookies;
  Stream<String> stream = response.transform(utf8.decoder);
  String body = await stream.join();

  String token = loginToken(body);
  request = await client.postUrl(Uri.parse(urlLogin));
  request.headers.set('content-type', 'application/x-www-form-urlencoded');
  request.cookies.addAll(cookies);
  body =
      'token=${Uri.encodeQueryComponent(token)}&username=${Uri.encodeQueryComponent(username)}&password=${Uri.encodeQueryComponent(password)}';
  request.add(utf8.encode(body));

  response = await request.close();
  stream = response.transform(utf8.decoder);
  body = await stream.join();

  request = await client.getUrl(Uri.parse(urlProducts));
  request.cookies.addAll(cookies);
  response = await request.close();
  stream = response.transform(utf8.decoder);
  body = await stream.join();

  List<String> products = productList(body);
  var usageList = List<Usage>();
  for (var productId in products) {
    String url = urlProduct.replaceAll(RegExp("{productId}"), productId);

    request = await client.getUrl(Uri.parse(url));
    request.followRedirects = false;
    request.cookies.addAll(cookies);
    response = await request.close();
    await response.transform(utf8.decoder).join();
    response = await response.redirect();

    List<Cookie> usageCookies = response.cookies;
    request = await client.getUrl(Uri.parse(urlUsage));
    request.cookies.add(cookies[0]);
    request.cookies.add(usageCookies[0]);
    request.cookies.add(usageCookies[4]);
    request.cookies.add(usageCookies[5]);
    request.cookies.add(usageCookies[6]);
    response = await request.close();

    stream = response.transform(utf8.decoder);
    body = await stream.join();

    var results = getProduct(body, productId);
    if (results.usage == null) {
      String username = _getInput(body, 'data-role', 'userName');
      request = await client
          .getUrl(Uri.parse(urlFibre + Uri.encodeQueryComponent(username)));
      response = await request.close();

      Stream<String> stream = response.transform(utf8.decoder);
      body = await stream.join();
      var map = json.decode(body);
      var usage = map['Data']['Usage'] / 1024 / 1024 / 1024;
      var total = map['Data']['Threshold'] / 1024 / 1024 / 1024;
      results.usage =
          '(${usage.toStringAsFixed(2)} GB of ${total.toStringAsFixed(2)} GB)';
    }
    usageList.add(results);
  }

  return usageList;
}

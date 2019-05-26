import 'dart:io';
import 'dart:convert';

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

Map<String, String> getProduct(String productPage, String productId) {
  Map<String, String> results = Map<String, String>();
  results["id"] = productId.substring(3);
  results["packageName"] = _getInput(productPage, 'data-role', 'packageName');
  results["lastUpdate"] = _getSpan(productPage,
      'ctl00_ctl00_contentDefault_contentControlPanel_lbllastUpdted');
  String lteUsage = _getSpan(productPage,
      'ctl00_ctl00_contentDefault_contentControlPanel_lblAnytimeCap');
  if (lteUsage != '')
    results["usage"] = lteUsage;
  else {
    results["usage"] = null;
  }
  return results;
}

Future<List<Map<String, String>>> getWebAfricaUsage(
    String username, String password) async {
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
  List<Map<String, String>> usageList = List<Map<String, String>>();
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
    if (results['usage'] == null) results['usage'] = 'Not Implemented';
    usageList.add(results);
  }

  return usageList;
}

import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:fibre_balance_check/webafrica.dart';

const String _username = 'username';
const String _password = 'password';

void main() {
  group('webafrica test', () {
    test('protocol test', () async {
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
          'token=${Uri.encodeQueryComponent(token)}&username=${Uri.encodeQueryComponent(_username)}&password=${Uri.encodeQueryComponent(_password)}';
      request.add(utf8.encode(body));

      response = await request.close();
      //cookies.addAll(response.cookies);
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

      print(usageList.toString());
    });

    test('worker test', () async {
      var usageList = await getWebAfricaUsage(_username, _password);
      for (var usage in usageList) {
        print('${usage['packageName']} = ${usage['usage']}');
      }
    });
  });
}

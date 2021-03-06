import 'dart:convert';
import 'dart:io';
import 'package:fibre_balance_check/common/html_utils.dart';
import 'package:fibre_balance_check/common/usage.dart';
import 'package:test/test.dart';
import 'package:fibre_balance_check/providers/webafrica.dart';

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
          "https://www.webafrica.co.za/clientarea.php?action=productdetails&id={productId}&modop=custom&a=LoginToDSLConsole";
      final String urlUsage = "https://usage.webafrica.co.za/usage.html";
      final String urlFibre =
          "https://www.webafrica.co.za/includes/fup.handler.php?cmd=getfupinfo&username=";

      HttpClient client = new HttpClient();
      var request = await client.getUrl(Uri.parse(urlHome));
      var response = await request.close();

      List<Cookie> cookies = response.cookies;
      Stream<String> stream = response.transform(utf8.decoder);
      String body = await stream.join();

      String token = getInput(body, "name", "token");
      request = await client.postUrl(Uri.parse(urlLogin));
      request.headers.set('content-type', 'application/x-www-form-urlencoded');
      request.cookies.addAll(cookies);
      body =
          'token=${Uri.encodeQueryComponent(token)}&username=${Uri.encodeQueryComponent(_username)}&password=${Uri.encodeQueryComponent(_password)}';
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
      List<Usage> usageList = List<Usage>();
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
          String username = getInput(body, 'data-role', 'userName');
          request = await client
              .getUrl(Uri.parse(urlFibre + Uri.encodeQueryComponent(username)));
          response = await request.close();

          Stream<String> stream = response.transform(utf8.decoder);
          body = await stream.join();
          var map = json.decode(body);
          results.usage = map['Data']['Usage'] / 1024 / 1024 / 1024;
          results.total = map['Data']['Threshold'] / 1024 / 1024 / 1024;
        }

        usageList.add(results);
      }

      print(usageList.toString());
    });

    test('worker test', () async {
      var webAfricaUsage = WebAfricaUsage();
      if (await webAfricaUsage.login(_username, _password)) {
        for (var productId in await webAfricaUsage.getProductList()) {
          var usage = await webAfricaUsage.getUsage(productId);
          print('${usage.id} ${usage.packageName} = ${usage.usage}');
        }
      } else {
        print('Login Failed');
      }
    });
  });

  test('usage parse', () {
    const usageStrings = [
      "(21,7 GB of 100 GB)",
      "(21,7 MB of 100,0 GB)",
      "(21.7 MB of 1000 MB)",
    ];
    const usageAmounts = [
      [21.7, 100],
      [0.0217, 100],
      [0.0217, 1]
    ];
    
    expect(usageStrings.length, usageAmounts.length, reason: "usage string should be equal to usage amounts");

    for (var i = 0; i < usageStrings.length; i++) {
      var actual = getAmounts(usageStrings[i]);
      expect(actual.length, 2, reason: "usage amount should contain [usage, total]");  
      var compare = usageAmounts[i];
      expect(compare.length, 2, reason: "usage amount should contain [usage, total]");

      expect(actual[0], compare[0], reason: "usage amount should match"); 
      expect(actual[1], compare[1], reason: "usage amount should match");  
    }
  });
}

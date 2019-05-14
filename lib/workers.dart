import 'dart:async';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

class WebAfricaChecker {
  final String urlHome = "https://www.webafrica.co.za/clientarea.php";
  final String urlLogin = "https://www.webafrica.co.za/dologin.php";
  final String urlProducts = "https://www.webafrica.co.za/myservices.php?pagetype=adsl";
  final String urlProduct = "https://www.webafrica.co.za/clientarea.php?action=productdetails&{productId}&modop=custom&a=LoginToDSLConsole";
  final String urlFibre = "https://www.webafrica.co.za/includes/fup.handler.php?cmd=getfupinfo&username=";

  Dio dio;
  WebAfricaChecker() {
    dio = new Dio();
    dio.interceptors.add(CookieManager(CookieJar()));
    //dio.cookieJar=new PersistCookieJar(dir:"./cookies");
  }

  bool isLoggedIn() {
    return false; // TODO: Check if clientarea presents login form
  }

  String _getInput(String page, String attrib, String value) {
    RegExp exp = new RegExp(r"\<input.*/>", multiLine: true);
    for (var match in exp.allMatches(page)) {
      String link = page.substring(match.start, match.end);
      if (link.contains(attrib + '="' + value + '"'))
      {
        exp = new RegExp(r'value=".*?"', multiLine: true);
        value = exp.stringMatch(link);
        if (value == null)
          return "";
        return value.substring(7, value.length - 1);
      }
    }
    return "";   
  }

  String _getSpan(String page, String spanId) {
    RegExp exp = new RegExp(r'\<span.*?\</span>', multiLine: true);
     for (var match in exp.allMatches(page)) {
      String span = page.substring(match.start, match.end);
      if (span.contains('id="' + spanId + '"'))
      {
        String text = span.substring(span.indexOf(RegExp(r'>')) + 1, span.length - 7);
        text = text.replaceAll(RegExp(r'\<b>'), '');
        text = text.replaceAll(RegExp(r'\</b>'), '');
        return text;
      }
    }
    return "";
  }

  Future<String> login(String username, String password) async {
    Response<String> body = await dio.get(urlHome);
    String token = _getInput(body.data, "name", "token");
    if (token == "")
      return "Home page does not contain login token";
    var formData = {
      "token": token,
      "username": username,
      "password": password,
      "rememberme": "on",
    };
    body = await dio.post(urlLogin, data: formData, options: Options(
      contentType: ContentType.parse("application/x-www-form-urlencoded"),
      validateStatus: (status) => status < 500,
    ));
    // TODO: Check if login failed
    return "";
  }

  Future<List<String>> getProductList() async {
    List<String> results = List<String>();

    Response<String> body = await dio.get(urlProducts);
    
    RegExp exp = RegExp(r'\<a.*>');
    for (var match in exp.allMatches(body.data)) {
      String link = body.data.substring(match.start, match.end);
      if (link.contains('LoginToDSLConsole')) {
        String id = RegExp(r'id=\d+').stringMatch(link);
        if (id != null) {
          results.add(id);
        }
      }
    }

    return results;
  }

  Future<Map<String, String>> getProduct(String productId) async {
    String url = urlProduct.replaceAll(RegExp("{productId}"), productId);

    Response<String> page = await dio.get(url);
    Map<String, String> results = Map<String, String>();
    results["id"] = productId.substring(3);
    results["packageName"] = _getInput(page.data, 'data-role', 'packageName');
    results["lastUpdate"] = _getSpan(page.data, 'ctl00_ctl00_contentDefault_contentControlPanel_lbllastUpdted');
    String lteUsage = _getSpan(page.data, 'ctl00_ctl00_contentDefault_contentControlPanel_lblAnytimeCap');
    if (lteUsage != '')
      results["usage"] = lteUsage;
    else {
      String username = _getInput(page.data, 'data-role', 'userName');
      // var response = await dio.get(urlFibre + username, json: true);
      // double usage = response['Data']['Usage'] / 1024 / 1024 / 1024;
      // double total = response['Data']['Threshold'] / 1024 / 1024 / 1024;
    }
    return results;
  }
}


class DummyChecker {
  bool isLoggedIn() {
    return false; 
  }

  Future<String> login(String username, String password) async {
    return Future.delayed(
      Duration(seconds: 2),
      () => ""
    );
  }

  Future<List<String>> getProductList() async {
    List<String> results = ["1", "2", "3"];
    return results;
  }

  Future<Map<String, String>> getProduct(String productId) async {
    Map<String, String> results = {
      "id": productId,
      "packageName": "",
      "lastUpdate": "2019-05-14 08:32",
      "usage": "",
    };

    if (productId == "1")
    {
      results["packageName"] = "Fibre 100G";
      results["usage"] = "70Gb of 100Gb";
    } else if (productId == "2")
    {
      results["packageName"] = "LTE 100G";
      results["usage"] = "24Gb of 100Gb";
    } else if (productId == "3")
    {
      results["packageName"] = "LTE 50G";
      results["usage"] = "49.8 of 50Gb";
    }
    
    return results;
  }
}

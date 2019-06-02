
String getInput(String page, String attrib, String value) {
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

String getSpan(String page, String spanId) {
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
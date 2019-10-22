import 'TextElement2.dart';

class NumberParser {
  List<TextElement2> source;

  double eDist;
  double eUsed;
  double gUsed;
  double gDist;

  NumberParser(this.source);

  parse() {
    final doubleRegex = RegExp(r'(\d+\.\d+)');
    String prev = '';
    String prev2 = '';
    String prev3 = '';
    String prev4 = '';
    String prev5 = '';
    for (var element in source) {
      //print(element.text);
      if (prev.startsWith('Usage')) {
        var firstMatch = doubleRegex.firstMatch(element.text);
        if (firstMatch != null) {
          String onlyNumbers = firstMatch.group(0);
          eDist = double.tryParse(onlyNumbers);
          print([prev, element.text, eDist].toString());
        }
      }
      if (prev2.startsWith('Usage')) {
        var firstMatch = doubleRegex.firstMatch(element.text);
        if (firstMatch != null) {
          String onlyNumbers = firstMatch.group(0);
          gDist = double.tryParse(onlyNumbers);
          print([prev2, element.text, gDist].toString());
        }
      }
      if (prev3.startsWith('Usage')) {
        var firstMatch = doubleRegex.firstMatch(element.text);
        if (firstMatch != null) {
          String onlyNumbers = firstMatch.group(0);
          eUsed = double.tryParse(onlyNumbers);
          print([prev3, element.text, eUsed].toString());
        }
      }
      if (prev5.startsWith('Usage')) {
        var firstMatch = doubleRegex.firstMatch(element.text);
        if (firstMatch != null) {
          String onlyNumbers = firstMatch.group(0);
          gUsed = double.tryParse(onlyNumbers);
          print([prev5, element.text, gUsed].toString());
        }
      }

      // next loop update
      prev5 = prev4;
      prev4 = prev3;
      prev3 = prev2;
      prev2 = prev;
      prev = element.text;
    }
  }
}

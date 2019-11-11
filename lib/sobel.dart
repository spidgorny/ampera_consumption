import 'dart:io';
import 'dart:math';

import 'package:image/image.dart';

void main() {
//  createGradient();
  naiveLineDetector();
}

void createGradient() {
  var sourceFile = File('./assets/IMG_20191020_124447.jpg');
  print(sourceFile);
  Image source = decodeImage(sourceFile.readAsBytesSync());
  Image gradient = sobel(source);
  File('assets/gradient.png')..writeAsBytesSync(encodePng(gradient));
}

// naive line detector
void naiveLineDetector() {
  print('Reading...');
  var gradientFile = File('./assets/gradient.png');
  Image gradient = decodeImage(gradientFile.readAsBytesSync());
  gradient = gaussianBlur(gradient, 4);
  print('width: ${gradient.width}');
  List<double> sumWhites = [];
  final rgba = gradient.getBytes(format: Format.luminance);
  for (int x = 0; x < gradient.width; x += 1) {
    var sum = 0.0;
    for (int y = 0; y < gradient.height; ++y) {
      var base = y * gradient.width + x;
      var r = rgba[base];
      sum += r / 255.0;
    }
    sumWhites.add(sum);
  }
  print('sumWhited: ${sumWhites.length}');
//  print(sumWhites);

  for (int i = 0; i < sumWhites.length; i++) {
    drawLine(gradient, i, gradient.height, i,
        gradient.height - sumWhites[i].floor(), Color.fromRgb(0, 255, 0));
  }
  File('assets/gradientLuminance.png')..writeAsBytesSync(encodePng(gradient));

  var maxVal = sumWhites.reduce((a, b) {
    return max(a, b);
  });
  print('maxVal: $maxVal');
  var limit = 0.80;
  var limitVal = maxVal * limit;
  print('limitVal: $limitVal');

  for (int i = 0; i < sumWhites.length; i++) {
    if (sumWhites[i] > limitVal) {
      var diff = sumWhites[i] - limitVal;
      print('$i / ${sumWhites.length}: +$diff');
    }
  }
}

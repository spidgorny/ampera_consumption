import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:smart_arrays_peaks/smart_arrays_peaks.dart';

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
  gradient = gaussianBlur(gradient, 10);
  print('width: ${gradient.width}');
  var sumWhites = getSumWhites(gradient);

  drawWhitesAsHisto(gradient, sumWhites);

  Float64List floatWhites = Float64List.fromList(sumWhites);
  var peaks = PeakPicker1D.detectPeaks(floatWhites, 0, floatWhites.length, 10.0,
      5.0, PeakPicker1D.PICK_POSNEG, 0);
  print(peaks);
  drawPeaks(gradient, sumWhites, peaks);

  File('assets/gradientLuminance.png')..writeAsBytesSync(encodePng(gradient));

  var maxVal = sumWhites.reduce((a, b) {
    return max(a, b);
  });
  print('maxVal: $maxVal');
  var limit = 0.77;
  var limitVal = maxVal * limit;
  print('limitVal: $limitVal');

  for (int i = 0; i < sumWhites.length; i++) {
    if (sumWhites[i] > limitVal && peaks.contains(i)) {
      var diff = sumWhites[i] - limitVal;
      print('$i / ${sumWhites.length}: +$diff');
    }
  }
}

List<double> getSumWhites(Image gradient) {
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
  return sumWhites;
}

void drawWhitesAsHisto(Image gradient, List<double> sumWhites) {
  for (int i = 0; i < sumWhites.length; i++) {
    drawLine(gradient, i, gradient.height, i,
        gradient.height - sumWhites[i].floor(), Color.fromRgb(0, 255, 0));
  }
}

void drawPeaks(Image gradient, List<double> sumWhites, peaks) {
  for (int peakX in peaks) {
    drawCircle(gradient, peakX, gradient.height - sumWhites[peakX].floor(), 10,
        Color.fromRgb(255, 0, 0));
  }
}

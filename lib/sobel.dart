import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:smart_arrays_peaks/smart_arrays_peaks.dart';

Future<dynamic> dirContents(Directory dir) {
  var files = <FileSystemEntity>[];
  var completer = new Completer();
  var lister = dir.list(recursive: false);
  lister.listen((file) => files.add(file),
      // should also register onError
      onDone: () => completer.complete(files));
  return completer.future;
}

void main() async {
//  var slicer1 = new SobelImageSlicer('./assets/IMG_20191020_124447.jpg');
//  slicer1.createGradient('assets/gradient.png');
//  slicer1.naiveLineDetector(
//      'assets/gradient.png', './assets/gradientLuminance.png');

  List<FileSystemEntity> files = await dirContents(Directory('./samples'));
  for (var file in files) {
    if (await FileSystemEntity.isDirectory(file.path)) {
      continue;
    }
    print(file);
    print(file.path);
    String baseName = basename(file.path);
    print(baseName);
    var slicer1 = new SobelImageSlicer(file.path);
    var gradient = './samples/gradient/$baseName';
    print(gradient);
    slicer1.createGradient(gradient);
    slicer1.naiveLineDetector(gradient, './samples/luminance/$baseName');
  }
}

class SobelImageSlicer {
  final String source;

  SobelImageSlicer(this.source);

  void createGradient(String destination) {
    var sourceFile = File(this.source);
    print(sourceFile);
    Image source = decodeImage(sourceFile.readAsBytesSync());
    Image gradient = sobel(source);
    File(destination)..writeAsBytesSync(encodePng(gradient));
  }

// naive line detector
  void naiveLineDetector(String source, String destination) {
    print('Reading...');
    var gradientFile = File(source);
    Image gradient = decodeImage(gradientFile.readAsBytesSync());
//  gradient = gaussianBlur(gradient, 10);
    gradient = copyResize(gradient,
        width: (gradient.width / 4).floor(),
        height: (gradient.height / 4).floor());
    print('width: ${gradient.width}');
    var sumWhites = getSumWhites(gradient);

    drawWhitesAsHisto(gradient, sumWhites);

    Float64List floatWhites = Float64List.fromList(sumWhites);
    var peaks = PeakPicker1D.detectPeaks(floatWhites, 0, floatWhites.length,
        10.0, 5.0, PeakPicker1D.PICK_POSNEG, 0);
    print(peaks);
    drawPeaks(gradient, sumWhites, peaks);

    File(destination)..writeAsBytesSync(encodePng(gradient));

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
      drawCircle(gradient, peakX, gradient.height - sumWhites[peakX].floor(),
          10, Color.fromRgb(255, 0, 0));
    }
  }
}

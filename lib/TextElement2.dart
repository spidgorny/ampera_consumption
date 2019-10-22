import 'dart:ui';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class TextElement2 {
  String text;
  List<Offset> cornerPoints;

  TextElement2(this.text, this.cornerPoints);

  factory TextElement2.from(TextElement source) {
    return TextElement2(source.text, source.cornerPoints);
  }
}

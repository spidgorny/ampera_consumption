import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class MyPainter extends CustomPainter {
  ImageInfo imageInfo;

  List<TextElement> textElements;

  MyPainter(this.imageInfo, this.textElements);

  @override
  void paint(Canvas canvas, Size size) {
    if (this.imageInfo == null) {
      return;
    }
    if (this.textElements.length == 0) {
      return;
    }
    // convert textElements into screen coordinates

    double zoomFactor = size.width / imageInfo.image.width;

    for (var element in textElements) {
      // we draw in screen coordinates
      final points = [
        element.boundingBox.topLeft * zoomFactor,
        element.boundingBox.topRight * zoomFactor,
        element.boundingBox.bottomRight * zoomFactor,
        element.boundingBox.bottomLeft * zoomFactor,
        element.boundingBox.topLeft * zoomFactor,
      ];
      final pointMode = ui.PointMode.polygon;
      final paint = Paint()
        ..color = Colors.green
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawPoints(pointMode, points, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

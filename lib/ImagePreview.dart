import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui show Image;

import 'package:extended_image/extended_image.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import 'MyPainter.dart';

class ImagePreview extends StatefulWidget {
  final String title = 'Ampera Consumption';
  String imageFile;

  ImagePreview({Key key, this.imageFile}) : super(key: key);

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  List<TextElement> textElements = List<TextElement>();

  void initState() {
    super.initState();
    this.detectTextFromImage();
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future detectTextFromImage() async {
    final File imageFile = File(widget.imageFile);
//        await getImageFileFromAssets('IMG_20191020_124447.jpg');
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    this.textElements.clear();
    String text = visionText.text;
    for (TextBlock block in visionText.blocks) {
      final Rect boundingBox = block.boundingBox;
      final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<RecognizedLanguage> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
//          text += element.text;
          print(element.text +
              "[" +
              element.cornerPoints.join(', ') +
              "]" +
              element.confidence.toString());
          this.textElements.add(element);
        }
      }
    }
    textRecognizer.close();

    this.calculateResults();
  }

  double eDist;
  double eUsed;

  void calculateResults() {
    final doubleRegex = RegExp(r'(\d+\.\d+)');
    String prev = '';
    String prev2 = '';
    String prev3 = '';
    for (var element in textElements) {
      print(element.text);
      if (prev.startsWith('Usage')) {
        String onlyNumbers = doubleRegex.firstMatch(element.text).group(0);
        eDist = double.tryParse(onlyNumbers);
        print([prev, element.text, eDist].join(' - '));
      }
      if (prev3.startsWith('Usage')) {
        String onlyNumbers = doubleRegex.firstMatch(element.text).group(0);
        eUsed = double.tryParse(onlyNumbers);
        print([prev3, element.text, eUsed].join(' - '));
      }

      // next loop update
      prev3 = prev2;
      prev2 = prev;
      prev = element.text;
    }
    setState(() {});
  }

  ImageInfo imageInfo;

  void listener(ImageInfo info, bool isSync) {
    print(info);
    setState(() {
      this.imageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
//    Image image = new Image.file(File(widget.imageFile));
    ExtendedImage image = ExtendedImage.file(File(widget.imageFile),
        fit: BoxFit.contain,
        //enableLoadState: false,
        mode: ExtendedImageMode.gesture, initGestureConfigHandler: (state) {
      print(state);
      return GestureConfig();
    }, afterPaintImage: afterPaint);
    image.image
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener(listener));

    // error: The argument type 'void Function(Canvas, Rect, Image, Paint)
    // (where Image is defined in
    // /Users/depidsvy/flutter/packages/flutter/lib/src/widgets/image.dart)'
    // can't be assigned to the parameter type
    // 'void Function(Canvas, Rect, Image, Paint)
    // (where Image is defined in
    // /Users/depidsvy/flutter/bin/cache/pkg/sky_engine/lib/ui/painting.dart)'.
    // (argument_type_not_assignable at [flutter_ampera_consumption]
    // lib/ImagePreview.dart:123)

    double eCons;
    String title;
    if (eUsed != null && eDist != null && eDist != 0) {
      eCons = eUsed / eDist * 100;
      title = eUsed.toString() +
          'kWh / ' +
          eDist.toString() +
          'km = ' +
          eCons.toStringAsFixed(2) +
          'kW/100km';
      print(title);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Stack(children: <Widget>[
            CustomPaint(
              foregroundPainter: MyPainter(this.imageInfo, this.textElements),
              child: image,
            )
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          detectTextFromImage();
        },
        tooltip: 'Redetect consumption',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void afterPaint(Canvas canvas, Rect rect, ui.Image image, Paint paint) {
    print(rect);
  }
}

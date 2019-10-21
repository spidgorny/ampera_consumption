import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TextElement> textElements = List<TextElement>();

  void initState() {
    super.initState();
    this._incrementCounter();
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  void _incrementCounter() async {
//    await detectTextFromImage();
    this.calculateResults();
  }

  Future detectTextFromImage() async {
    final File imageFile =
        await getImageFileFromAssets('IMG_20191020_124447.jpg');
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

  final imageOfScreen = 'assets/IMG_20191020_124447.jpg';

  ImageInfo imageInfo;

  void listener(ImageInfo info, bool isSync) {
    print(info);
    setState(() {
      this.imageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    Image image = new Image.asset(imageOfScreen);
    image.image
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener(listener));

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
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

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
    return false;
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ampera_consumption/CameraWidget.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    initAsyncState();
  }

  initAsyncState() async {
    cameras = await availableCameras();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ampera Consumption',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
//      home: ImagePreview(),
      home: cameras.length == 0
          ? CircularProgressIndicator()
          : CameraWidget(cameras[0]),
    );
  }
}

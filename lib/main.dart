import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ampera_consumption/CameraWidget.dart';

List<CameraDescription> cameras;

void main() async {
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ampera Consumption',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
//      home: ImagePreview(),
      home: CameraWidget(cameras[0]),
    );
  }
}

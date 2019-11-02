import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CameraWidget.dart';

class CameraSelector extends StatefulWidget {
  @override
  _CameraSelectorState createState() => _CameraSelectorState();
}

class _CameraSelectorState extends State<CameraSelector> {
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
        home: cameras.length == 0
            ? CircularProgressIndicator()
            : CameraWidget(cameras[0]));
  }
}

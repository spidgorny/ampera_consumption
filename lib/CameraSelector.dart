import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CameraWidget.dart';

class CameraSelector extends StatefulWidget {
  @override
  _CameraSelectorState createState() {
    print('CameraSelector->createState');
    return _CameraSelectorState();
  }
}

class _CameraSelectorState extends State<CameraSelector> {
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    print('initState');
    super.initState();
    initAsyncState();
  }

  initAsyncState() async {
    print('initAsyncState');
    var cameras = await availableCameras();
    setState(() {
      this.cameras = cameras;
    });
    print('initAsyncState: ' + cameras.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    print('cameras.length: ' + cameras.length.toString());
    return cameras.length == 0
        ? Scaffold(
            appBar: AppBar(
              title: Text('Checking cameras'),
            ),
            body: Center(child: CircularProgressIndicator()),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  this.initAsyncState();
                },
                child: Icon(Icons.refresh)),
          )
        : CameraWidget(cameras[0]);
  }
}

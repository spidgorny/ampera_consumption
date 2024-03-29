import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

import 'ImagePreview.dart';

class CameraWidget extends StatefulWidget {
  final camera;

  CameraWidget(this.camera, {key: Key}) : super();

  @override
  _CameraWidgetState createState() => new _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController controller;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String imagePath;
  String version;

  @override
  void initState() {
    super.initState();
    initCamera();
    initAsync();
  }

  void initCamera() {
    controller = new CameraController(widget.camera, ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  void initAsync() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

//    String appName = packageInfo.appName;
//    String packageName = packageInfo.packageName;
    setState(() {
      version = packageInfo.version;
    });
//    String buildNumber = packageInfo.buildNumber;
  }

  void _fabClick(context) {
    takePicture().then((String filePath) async {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        if (filePath != null) {
          //showInSnackBar('Picture saved to $filePath');

          var result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImagePreview(imageFile: filePath)),
          );

          // after Navigator.pop
          this.initCamera();
        }
      }
    });
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    print('************* CAMERA DISPOSED ***************');
    controller?.dispose();
    super.dispose();
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    var filePath = await this.getNewFilename();
    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<String> getNewFilename() async {
    final Directory extDir = await getTemporaryDirectory();
    await Directory(extDir.path).create(recursive: true);
    final String filePath = '${extDir.path}/${timestamp()}.jpg';
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return RotatedBox(
          quarterTurns: isLandscape() ? 3 : 0,
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ));
    }
  }

  bool isLandscape() =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return new Container();
    }

    var title = 'Make a photo of the consumption screen';

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(
            title,
          ),
          actions: <Widget>[
            FlatButton(
                child: Text(
                  'Demo',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  ByteData data =
                      await rootBundle.load("assets/IMG_20191020_124447.jpg");
                  List<int> bytes = data.buffer
                      .asUint8List(data.offsetInBytes, data.lengthInBytes);
                  var filePath = await this.getNewFilename();
                  await File(filePath).writeAsBytes(bytes);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ImagePreview(imageFile: filePath)),
                  );
                }),
          ],
        ),
        body: new Center(
          child: new SingleChildScrollView(
            child: _cameraPreviewWidget(),
          ),
        ),
        floatingActionButton: Container(
            height: 100.0,
            width: 100.0,
            child: FittedBox(
                child: new FloatingActionButton(
              onPressed: () => _fabClick(context),
              tooltip: 'Make Photo',
              child: new Icon(Icons.camera),
            ))),
        floatingActionButtonLocation: isLandscape()
            ? FloatingActionButtonLocation.endFloat
            : FloatingActionButtonLocation.centerFloat
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_ampera_consumption/CheckPermissions.dart';

import 'locator.dart';

void main() async {
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ampera Consumption',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
//      navigatorKey: locator<NavigationService>().navigatorKey,
      home: CheckPermissions(
        title: 'Ampera Consumption',
      ),
    );
  }
}

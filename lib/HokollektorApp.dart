import 'package:flutter/material.dart';

class HokollektorApp extends StatelessWidget {
  final Widget child;

  const HokollektorApp({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Collector App',
      theme: new ThemeData(
        fontFamily: 'Rubik',
        primarySwatch: Colors.blue,
      ),
      home: child,
    );
  }
}

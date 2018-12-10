import 'package:flutter/material.dart';
import 'package:hokollektor/localization.dart';

Locale locale;

class HokollektorApp extends StatelessWidget {
  final Widget child;

  const HokollektorApp({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
//

    return new MaterialApp(
      supportedLocales:
          localizations.map((languageCode) => Locale(languageCode)).toList(),
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

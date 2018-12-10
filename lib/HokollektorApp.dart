import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hokollektor/localization.dart';

Locale locale;

class HokollektorApp extends StatelessWidget {
  final Widget child;

  const HokollektorApp({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
//

    return new MaterialApp(
      localizationsDelegates: localizations
          .map((languageCode) => GlobalMaterialLocalizations.delegate)
          .toList(),

      // ... app-specific localization delegate[s] here

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

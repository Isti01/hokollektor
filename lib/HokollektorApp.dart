import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hokollektor/Localization.dart';

const AppFontFamily = "Rubik";
const AppTitle = 'Collector App';

class HokollektorApp extends StatelessWidget {
  final Widget child;

  const HokollektorApp({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: localizations.map((languageCode) {
        return Locale(languageCode);
      }).toList(),
      debugShowCheckedModeBanner: false,
      title: AppTitle,
      theme: ThemeData(
        fontFamily: AppFontFamily,
        primarySwatch: Colors.blue,
      ),
      home: LocaleInitializerLayer(child: child),
    );
  }
}

class LocaleInitializerLayer extends StatefulWidget {
  final child;

  const LocaleInitializerLayer({Key key, this.child}) : super(key: key);

  @override
  LocaleInitializerLayerState createState() {
    return new LocaleInitializerLayerState();
  }
}

class LocaleInitializerLayerState extends State<LocaleInitializerLayer> {
  var key = UniqueKey();

  @override
  void initState() {
    super.initState();
    onLocaleChange = () => this.setState(() => key = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    initLocale(
        preferredLanguage ?? Localizations.localeOf(context).languageCode);
    return Container(key: key, child: widget.child);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hokollektor/localization.dart';

const kAppFontFamily = "Rubik";
const kAppTitle = 'Collector App';

class CollectorApp extends StatelessWidget {
  final Widget child;

  const CollectorApp({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: localizations.map((languageCode) {
        return Locale(languageCode);
      }).toList(),
      debugShowCheckedModeBanner: false,
      title: kAppTitle,
      theme: ThemeData(
        fontFamily: kAppFontFamily,
        primarySwatch: Colors.blue,
      ),
      home: LocaleInitializerLayer(child: child),
    );
  }
}

class LocaleInitializerLayer extends StatefulWidget {
  final Widget child;

  const LocaleInitializerLayer({Key key, this.child}) : super(key: key);

  @override
  LocaleInitializerLayerState createState() => LocaleInitializerLayerState();
}

class LocaleInitializerLayerState extends State<LocaleInitializerLayer> {
  var key = UniqueKey();

  @override
  void initState() {
    super.initState();
    onLocaleChange = () => setState(() => key = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    initLocale(
        preferredLanguage ?? Localizations.localeOf(context).languageCode);
    return Container(key: key, child: widget.child);
  }
}

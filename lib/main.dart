import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hokollektor/collector_app.dart';
import 'package:hokollektor/home/home.dart';
import 'package:hokollektor/localization.dart';
import 'package:hokollektor/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool inGuestMode = false;

const String stayLoggedInKey = 'stayLoggedIn';
const String languagePrefKey = 'language';

void main() async {
  setPortraitOrientation();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool loggedIn = false;
  String chosenLanguage;

  try {
    loggedIn = prefs.getBool(stayLoggedInKey) ?? false;
  } catch (e) {
    developer.log(e.toString());
  }

  try {
    chosenLanguage = prefs.getString(languagePrefKey);

    if (chosenLanguage != null && chosenLanguage.trim().isEmpty) {
      chosenLanguage = null;
    }
  } catch (e) {
    developer.log(e.toString());
  }

  preferredLanguage = chosenLanguage;

  if (loggedIn) {
    runApp(const CollectorApp(child: HomePage()));
  } else {
    runApp(const CollectorApp(child: LoginPage()));
  }
}

setPortraitOrientation() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

setLandscapeOrientation() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

showSystemOverlay() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
}

hideSystemOverlay() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}

saveLanguagePreference(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (languageCode.trim().isEmpty) languageCode = null;

  prefs.setString(languagePrefKey, languageCode);

  preferredLanguage = languageCode;
}

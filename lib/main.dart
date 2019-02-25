import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hokollektor/HokollektorApp.dart';
import 'package:hokollektor/Localization.dart';
import 'package:hokollektor/home/Home.dart';
import 'package:hokollektor/login/Login.dart';
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
    print(e.toString());
  }

  try {
    chosenLanguage = prefs.getString(languagePrefKey);

    if (chosenLanguage != null && chosenLanguage.trim().isEmpty)
      chosenLanguage = null;
  } catch (e) {
    print(e.toString());
  }

  preferredLanguage = chosenLanguage;

  if (loggedIn)
    runApp(HokollektorApp(child: HomePage()));
  else
    runApp(HokollektorApp(child: LoginPage()));
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
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
}

hideSystemOverlay() {
  SystemChrome.setEnabledSystemUIOverlays([]);
}

saveLanguagePreference(String languageCode) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (languageCode.trim().isEmpty) languageCode = null;

  prefs.setString(languagePrefKey, languageCode);

  preferredLanguage = languageCode;
}

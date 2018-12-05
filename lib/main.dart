import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hokollektor/HokollektorApp.dart';
import 'package:hokollektor/home/Home.dart';
import 'package:hokollektor/login/Login.dart';
import 'package:hokollektor/util/URLs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool loggedIn = false;

  try {
    loggedIn = prefs.getBool(stayLoggedInKey) ?? false;
  } catch (e) {
    print(e.toString());
  }
  if (loggedIn)
    runApp(HokollektorApp(child: HomePage()));
  else
    runApp(HokollektorApp(child: LoginPage()));
}

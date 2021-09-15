import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> isConnected() async =>
    await (Connectivity().checkConnectivity()) != ConnectivityResult.none;

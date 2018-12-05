import 'package:connectivity/connectivity.dart';

Future<bool> isConnected() async =>
    await (new Connectivity().checkConnectivity()) != ConnectivityResult.none;

import 'dart:convert';
import "dart:developer" as developer;

import 'package:charts_common/common.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/networking.dart';
import 'package:http/http.dart' as http;

const tempHouseKey = 'bnt';
const tempOutsideKey = 'knt';
const tempCollKey = 'kll';
const dateKey = 'dt';
const wattKey = 'w';

final List<Color> chartColors = [
  charts.MaterialPalette.red.shadeDefault,
  charts.MaterialPalette.blue.shadeDefault,
  charts.MaterialPalette.yellow.shadeDefault,
];

Future<List<charts.Series<ChartDataPoint, DateTime>>?> fetchChartData(
    String url,
    [bool wattChart = false]) async {
  if (!(await isConnected())) return null;

  http.Response connection = await http.get(Uri.parse(url));

  String body = connection.body;

  final json = jsonDecode(body);
  if (wattChart) {
    return parseWattChartData(json);
  } else {
    return parseChartData(json);
  }
}

class ChartDataPoint {
  final DateTime date;
  final double value;

  ChartDataPoint({required this.date, required this.value});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json, String key) {
    return ChartDataPoint(
      date: DateTime.parse(json[dateKey]),
      value: json[key] is double
          ? json[key]
          : json[key] is num
              ? json[key].toDouble()
              : double.parse(json[key]),
    );
  }
}

List<charts.Series<ChartDataPoint, DateTime>>? parseChartData(json) {
  List<ChartDataPoint> outside = [];
  List<ChartDataPoint> house = [];
  List<ChartDataPoint> coll = [];

  var collData = json['adatokkollektor'];
  if (collData == null) return null;

  for (var subJson in collData) {
    try {
      outside.add(ChartDataPoint.fromJson(subJson, tempOutsideKey));
      house.add(ChartDataPoint.fromJson(subJson, tempHouseKey));
      coll.add(ChartDataPoint.fromJson(subJson, tempCollKey));
    } catch (e, s) {
      developer.log([e, s].toString());
    }
  }

  return [
    charts.Series<ChartDataPoint, DateTime>(
        id: 'Kollektor',
        colorFn: (_, __) => chartColors[0],
        domainFn: (ChartDataPoint point, _) => point.date,
        measureFn: (ChartDataPoint point, _) => point.value,
        data: coll,
        displayName: loc.getText(loc.koll)),
    charts.Series<ChartDataPoint, DateTime>(
        id: 'Kint',
        colorFn: (_, __) => chartColors[1],
        domainFn: (ChartDataPoint point, _) => point.date,
        measureFn: (ChartDataPoint point, _) => point.value,
        data: outside,
        displayName: loc.getText(loc.outside)),
    charts.Series<ChartDataPoint, DateTime>(
        id: 'Benti',
        colorFn: (_, __) => chartColors[2],
        domainFn: (ChartDataPoint point, _) => point.date,
        measureFn: (ChartDataPoint point, _) => point.value,
        data: house,
        displayName: loc.getText(loc.inside)),
  ];
}

List<charts.Series<ChartDataPoint, DateTime>>? parseWattChartData(json) {
  List<ChartDataPoint> watt = [];

  var collData = json['adatokkollektor'];
  if (collData == null) return null;

  for (var subJson in collData) {
    try {
      watt.add(ChartDataPoint.fromJson(subJson, wattKey));
    } catch (e, s) {
      developer.log([e, s].toString());
      return null;
    }
  }

  return [
    charts.Series<ChartDataPoint, DateTime>(
        id: 'Watt',
        colorFn: (_, __) => chartColors[1],
        domainFn: (ChartDataPoint point, _) => point.date,
        measureFn: (ChartDataPoint point, _) => point.value,
        data: watt,
        displayName: loc.getText(loc.performance)),
  ];
}

class ChartResponse {
  final List<charts.Series<ChartDataPoint, DateTime>> data;
  final bool hasError;
  final String errorMessage;

  ChartResponse({
    this.data = const [],
    this.hasError = false,
    this.errorMessage = '',
  });

  factory ChartResponse.success(
          List<charts.Series<ChartDataPoint, DateTime>> data) =>
      ChartResponse(data: data);

  factory ChartResponse.failed(String message) => ChartResponse(
        hasError: true,
        errorMessage: message,
      );
}

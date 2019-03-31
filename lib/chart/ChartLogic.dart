import 'dart:convert';

import 'package:charts_common/common.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:hokollektor/Localization.dart' as loc;
import 'package:hokollektor/util/Networking.dart';
import 'package:http/http.dart' as http;

const tempBent = 'bnt';
const tempKint = 'knt';
const tempKoll = 'kll';
const datum = 'dt';
const wattKey = 'w';

final List<Color> chartColors = [
  charts.MaterialPalette.red.shadeDefault,
  charts.MaterialPalette.blue.shadeDefault,
  charts.MaterialPalette.yellow.shadeDefault,
];

Future<List<charts.Series<ChartDataPoint, DateTime>>> fetchChartData(String url,
    [bool wattChart = false]) async {
  if (!(await isConnected())) return null;

  http.Response connection = await http.get(url);

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

  ChartDataPoint({this.date, this.value});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json, String key) {
    return ChartDataPoint(
      date: DateTime.parse(json[datum]),
      value: json[key] is double
          ? json[key]
          : json[key] is num ? json[key].toDouble() : double.parse(json[key]),
    );
  }
}

List<charts.Series<ChartDataPoint, DateTime>> parseChartData(json) {
  List<ChartDataPoint> kinti = [];
  List<ChartDataPoint> benti = [];
  List<ChartDataPoint> koll = [];

  try {
    for (var subJson in json['adatokkollektor']) {
      kinti.add(ChartDataPoint.fromJson(subJson, tempKint));
      benti.add(ChartDataPoint.fromJson(subJson, tempBent));
      koll.add(ChartDataPoint.fromJson(subJson, tempKoll));
    }

    final result = [
      charts.Series<ChartDataPoint, DateTime>(
          id: 'Kollektor',
          colorFn: (_, __) => chartColors[0],
          domainFn: (ChartDataPoint sales, _) => sales.date,
          measureFn: (ChartDataPoint sales, _) => sales.value,
          data: koll,
          displayName: loc.getText(loc.koll)),
      charts.Series<ChartDataPoint, DateTime>(
          id: 'Kint',
          colorFn: (_, __) => chartColors[1],
          domainFn: (ChartDataPoint sales, _) => sales.date,
          measureFn: (ChartDataPoint sales, _) => sales.value,
          data: kinti,
          displayName: loc.getText(loc.outside)),
      charts.Series<ChartDataPoint, DateTime>(
          id: 'Benti',
          colorFn: (_, __) => chartColors[2],
          domainFn: (ChartDataPoint sales, _) => sales.date,
          measureFn: (ChartDataPoint sales, _) => sales.value,
          data: benti,
          displayName: loc.getText(loc.inside)),
    ];
    return result;
  } catch (e) {
    print(e.toString());
    return null;
  }
}

List<charts.Series<ChartDataPoint, DateTime>> parseWattChartData(json) {
  List<ChartDataPoint> watt = [];

  try {
    for (var subJson in json['adatokkollektor']) {
      watt.add(ChartDataPoint.fromJson(subJson, wattKey));
    }

    final result = [
      charts.Series<ChartDataPoint, DateTime>(
          id: 'Watt',
          colorFn: (_, __) => chartColors[1],
          domainFn: (ChartDataPoint sales, _) => sales.date,
          measureFn: (ChartDataPoint sales, _) => sales.value,
          data: watt,
          displayName: loc.getText(loc.performance)),
    ];
    return result;
  } catch (e) {
    print(e.toString());
    return null;
  }
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

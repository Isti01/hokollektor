import 'dart:convert';

import 'package:charts_common/common.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:hokollektor/util/network.dart';
import 'package:http/http.dart' as http;

final List<Color> chartColors = [
  charts.MaterialPalette.red.shadeDefault,
  charts.MaterialPalette.blue.shadeDefault,
  charts.MaterialPalette.yellow.shadeDefault,
];

Future<List<charts.Series<ChartDataPoint, DateTime>>> fetchChartData(
    String url) async {
  if (!(await isConnected())) return null;

  http.Response connection = await http.get(url);

  String body = connection.body;

  Map<String, dynamic> json = jsonDecode(body);

  final data = _parseData(json);

  return data;
}

class ChartDataPoint {
  final DateTime date;
  final double value;

  ChartDataPoint({this.date, this.value});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json, String key) {
    return ChartDataPoint(
      date: DateTime.parse(json['datum']),
      value: json[key] is double
          ? json[key]
          : json[key] is num ? json[key].toDouble() : double.parse(json[key]),
    );
  }
}

List<charts.Series<ChartDataPoint, DateTime>> _parseData(
    Map<String, dynamic> json) {
  List<ChartDataPoint> kinti = [];
  List<ChartDataPoint> benti = [];
  List<ChartDataPoint> koll = [];

  try {
    for (Map<String, dynamic> subJson in json['adatokkollektor']) {
      kinti.add(ChartDataPoint.fromJson(subJson, 'tempKinti'));
      benti.add(ChartDataPoint.fromJson(subJson, 'tempBent'));
      koll.add(ChartDataPoint.fromJson(subJson, 'tempKoll'));
    }

    final result = [
      charts.Series<ChartDataPoint, DateTime>(
          id: 'Kollektor',
          colorFn: (_, __) => chartColors[0],
          domainFn: (ChartDataPoint sales, _) => sales.date,
          measureFn: (ChartDataPoint sales, _) => sales.value,
          data: koll,
          displayName: 'Kollektor'),
      charts.Series<ChartDataPoint, DateTime>(
          id: 'Kint',
          colorFn: (_, __) => chartColors[1],
          domainFn: (ChartDataPoint sales, _) => sales.date,
          measureFn: (ChartDataPoint sales, _) => sales.value,
          data: kinti,
          displayName: 'Kint'),
      charts.Series<ChartDataPoint, DateTime>(
          id: 'Benti',
          colorFn: (_, __) => chartColors[2],
          domainFn: (ChartDataPoint sales, _) => sales.date,
          measureFn: (ChartDataPoint sales, _) => sales.value,
          data: benti,
          displayName: 'Benti'),
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

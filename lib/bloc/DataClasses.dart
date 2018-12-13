import 'package:charts_flutter/flutter.dart' as charts;
import 'package:hokollektor/chart/ChartLogic.dart';
import 'package:hokollektor/util/URLs.dart';

abstract class DataEvent {
  const DataEvent();
}

class DataUpdateEvent extends DataEvent {
  final InformationHolder tempData;
  final List<charts.Series<ChartDataPoint, DateTime>> kollData;
  final profileState profileData;
  final Rpm manualData;

  const DataUpdateEvent({
    this.manualData,
    this.tempData,
    this.kollData,
    this.profileData,
  });
}

class DataErrorEvent extends DataEvent {
  final String message;

  const DataErrorEvent({this.message});
}

class AppDataState {
  final bool failed, loading;
  final String errorMessage;
  final InformationHolder tempData;
  final List<charts.Series<ChartDataPoint, DateTime>> kollData;
  final profileState profileData;
  final Rpm manualData;

  const AppDataState({
    this.manualData,
    this.errorMessage,
    this.failed = false,
    this.loading = false,
    this.tempData,
    this.kollData = const [],
    this.profileData,
  });

  factory AppDataState.init({tempData, kollData, profileData, manualData}) =>
      AppDataState(
        loading: true,
        tempData: tempData,
        kollData: kollData,
        profileData: profileData,
        manualData: manualData,
      );

  factory AppDataState.error(errorMessage) => AppDataState(
        failed: true,
        errorMessage: errorMessage,
      );
}

class InformationHolder {
  String legkisebbKoll;
  String legkisebbBenti;
  String legnagyobbKoll;
  String legnagyobbBenti;
  String jelenlegKint;
  String jelenlegBent;
  String jelenlegKoll;

  InformationHolder({
    this.legkisebbKoll,
    this.legkisebbBenti,
    this.legnagyobbKoll,
    this.legnagyobbBenti,
    this.jelenlegKint,
    this.jelenlegBent,
    this.jelenlegKoll,
  });

  InformationHolder.fromJson(Map<String, dynamic> json) {
    legkisebbKoll = json['legkisebbKoll'];
    legkisebbBenti = json['legkisebbBenti'];
    legnagyobbKoll = json['legnagyobbKoll'];
    legnagyobbBenti = json['legnagyobbBenti'];
    jelenlegKint = json['jelenlegKint'];
    jelenlegBent = json['jelenlegBent'];
    jelenlegKoll = json['jelenlegKoll'];
  }
}

/*class ChartDataPoint {
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
}*/

enum profileState {
  optimal,
  minimal,
  maximal,
  manual,
  custom,
}

int getProfileNumber(profileState profile) {
  switch (profile) {
    case profileState.optimal:
      return 1;
    case profileState.minimal:
      return 3;
    case profileState.maximal:
      return 2;
    case profileState.manual:
      return 4;
    case profileState.custom:
      return 5;
  }
  return 1;
}

profileState getProfileState(int number) {
  switch (number) {
    case 1:
      return profileState.optimal;
    case 3:
      return profileState.minimal;
    case 2:
      return profileState.maximal;
    case 4:
      return profileState.manual;
    case 5:
      return profileState.custom;
    default:
      return profileState.optimal;
  }
}

String createProfileURL(profileState profile) {
  return ProfileSubmitURL + getProfileNumber(profile).toString();
}

profileState parseProfileData(json) {
  int profileNumber = int.parse(json['profile']);

  return getProfileState(profileNumber);
}

class Rpm {
  bool enabled;
  int rpm1;
  int rpm2;

  Rpm({this.enabled, this.rpm1, this.rpm2});

  Rpm.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
    rpm1 = int.parse(json['rpm1']);
    rpm2 = int.parse(json['rpm2']);
  }
}

String createManualURL(int speed0, int speed1, bool enabled) {
  return RpmSubmitURL +
      "?adat1=${enabled != null && enabled ? 1 : 0}&adat2=$speed0&adat3=$speed1";
}

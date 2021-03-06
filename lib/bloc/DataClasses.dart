import 'package:charts_flutter/flutter.dart' as charts;
import 'package:hokollektor/chart/ChartLogic.dart';
import 'package:hokollektor/util/URLs.dart';

abstract class DataEvent {
  const DataEvent();
}

class DataUpdateEvent extends DataEvent {
  final reload;
  final InformationHolder tempData;
  final List<charts.Series<ChartDataPoint, DateTime>> kollData;
  final profileState profileData;
  final Rpm manualData;
  final double kwhData;

  const DataUpdateEvent({
    this.manualData,
    this.tempData,
    this.kollData,
    this.profileData,
    this.kwhData,
    this.reload = false,
  });
}

class DataErrorEvent extends DataEvent {
  const DataErrorEvent();
}

class AppDataState {
  final bool tempLoaded, profileLoaded;
  final bool kollFailed,
      profileFailed,
      manualFailed,
      tempFailed,
      kwhFailed,
      loading;
  final InformationHolder tempData;
  final List<charts.Series<ChartDataPoint, DateTime>> kollData;
  final profileState profileData;
  final Rpm manualData;
  final double kwhData;

  const AppDataState({
    this.tempLoaded,
    this.profileLoaded,
    this.manualData,
    this.loading = false,
    this.tempData,
    this.kollData = const [],
    this.profileData,
    this.kwhData,
    this.kollFailed = false,
    this.profileFailed = false,
    this.manualFailed = false,
    this.tempFailed = false,
    this.kwhFailed,
  });

  factory AppDataState.init({
    tempData,
    kollData,
    profileData,
    manualData,
    kwhData,
  }) =>
      AppDataState(
        tempLoaded: false,
        profileLoaded: false,
        loading: true,
        tempData: tempData,
        kollData: kollData,
        profileData: profileData,
        manualData: manualData,
        kwhData: kwhData,
      );

  factory AppDataState.error(errorMessage) => AppDataState(
        tempLoaded: false,
        profileLoaded: false,
        kollFailed: true,
        profileFailed: true,
        manualFailed: true,
        tempFailed: true,
        kwhFailed: false,
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

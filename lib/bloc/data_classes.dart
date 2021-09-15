import 'package:charts_flutter/flutter.dart' as charts;
import 'package:hokollektor/chart/chart_logic.dart';
import 'package:hokollektor/util/urls.dart';

abstract class DataEvent {
  const DataEvent();
}

class DataUpdateEvent extends DataEvent {
  final bool reload;
  final TemperatureStatistics? tempData;
  final List<charts.Series<ChartDataPoint, DateTime>>? collectorData;
  final ProfileState? profileData;
  final RpmData? manualData;
  final double? kwhData;

  const DataUpdateEvent({
    this.manualData,
    this.tempData,
    this.collectorData,
    this.profileData,
    this.kwhData,
    this.reload = false,
  });
}

class DataErrorEvent extends DataEvent {
  const DataErrorEvent();
}

class AppDataState {
  final bool tempLoaded;
  final bool profileLoaded;
  final bool collFailed;
  final bool profileFailed;
  final bool manualFailed;
  final bool tempFailed;
  final bool loading;
  final TemperatureStatistics? tempData;
  final List<charts.Series<ChartDataPoint, DateTime>>? collData;
  final ProfileState? profileData;
  final RpmData? manualData;
  final double? kwhData;

  const AppDataState({
    required this.tempLoaded,
    required this.profileLoaded,
    this.manualData,
    this.loading = false,
    this.tempData,
    this.collData = const [],
    this.profileData,
    this.kwhData,
    this.collFailed = false,
    this.profileFailed = false,
    this.manualFailed = false,
    this.tempFailed = false,
  });

  factory AppDataState.init({
    tempData,
    collData,
    profileData,
    manualData,
    kwhData,
  }) =>
      AppDataState(
        tempLoaded: false,
        profileLoaded: false,
        loading: true,
        tempData: tempData,
        collData: collData,
        profileData: profileData,
        manualData: manualData,
        kwhData: kwhData,
      );

  factory AppDataState.error(errorMessage) => const AppDataState(
        tempLoaded: false,
        profileLoaded: false,
        collFailed: true,
        profileFailed: true,
        manualFailed: true,
        tempFailed: true,
      );
}

class TemperatureStatistics {
  String? minCollector;
  String? minHouse;
  String? maxCollector;
  String? maxHouse;
  String? currentOutside;
  String? currentHouse;
  String? currentCollector;

  TemperatureStatistics({
    this.minCollector,
    this.minHouse,
    this.maxCollector,
    this.maxHouse,
    this.currentOutside,
    this.currentHouse,
    this.currentCollector,
  });

  TemperatureStatistics.fromJson(Map<String, dynamic> json) {
    minCollector = json['legkisebbKoll'];
    minHouse = json['legkisebbBenti'];
    maxCollector = json['legnagyobbKoll'];
    maxHouse = json['legnagyobbBenti'];
    currentOutside = json['jelenlegKint'];
    currentHouse = json['jelenlegBent'];
    currentCollector = json['jelenlegKoll'];
  }
}

enum ProfileState {
  optimal,
  minimal,
  maximal,
  manual,
  custom,
}

int getProfileNumber(ProfileState profile) {
  switch (profile) {
    case ProfileState.optimal:
      return 1;
    case ProfileState.minimal:
      return 3;
    case ProfileState.maximal:
      return 2;
    case ProfileState.manual:
      return 4;
    case ProfileState.custom:
      return 5;
  }
}

ProfileState getProfileState(int number) {
  switch (number) {
    case 1:
      return ProfileState.optimal;
    case 3:
      return ProfileState.minimal;
    case 2:
      return ProfileState.maximal;
    case 4:
      return ProfileState.manual;
    case 5:
      return ProfileState.custom;
    default:
      return ProfileState.optimal;
  }
}

String createProfileURL(ProfileState profile) {
  return kProfileSubmitURL + getProfileNumber(profile).toString();
}

ProfileState parseProfileData(json) {
  int profileNumber = int.parse(json['profile']);

  return getProfileState(profileNumber);
}

class RpmData {
  bool? enabled;
  int? rpm1;
  int? rpm2;

  RpmData({this.enabled, this.rpm1, this.rpm2});

  RpmData.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
    rpm1 = int.parse(json['rpm1']);
    rpm2 = int.parse(json['rpm2']);
  }
}

String createManualURL(int? speed0, int? speed1, bool? enabled) {
  return kRpmSubmitURL +
      "?adat1=${enabled != null && enabled ? 1 : 0}&adat2=$speed0&adat3=$speed1";
}

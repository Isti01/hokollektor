import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:hokollektor/bloc/data_classes.dart';
import 'package:hokollektor/chart/chart_logic.dart';
import 'package:hokollektor/util/networking.dart';
import 'package:hokollektor/util/urls.dart' as urls;
import 'package:http/http.dart' as http;

const reloadAfter = 15;

class AppBloc extends Bloc<DataEvent, AppDataState> {
  late Timer timer;
  bool loaded = false,
      fetching = false,
      uploadingManual = false,
      uploadingProfile = false;

  AppBloc() : super(AppDataState.init()) {
    _startFetching();
  }

  _startFetching() {
    _fetchData();
    fetching = true;
    timer = Timer.periodic(const Duration(seconds: reloadAfter), (timer) {
      if (!fetching) _fetchData();
    });
  }

  void reload() {
    if (!fetching) {
      _fetchData();
    }

    add(const DataUpdateEvent(
      reload: true,
    ));
  }

  @override
  Stream<AppDataState> mapEventToState(DataEvent event) async* {
    if (event is DataUpdateEvent) {
      final kwhData = event.kwhData ?? state.kwhData;
      yield AppDataState(
        loading: event.reload,
        profileData: event.profileData ?? state.profileData,
        tempData: event.tempData ?? state.tempData,
        manualData: event.manualData ?? state.manualData,
        collData: event.collectorData ?? state.collData,
        kwhData: kwhData,
        profileLoaded: (event.profileData ?? state.profileData) != null,
        tempLoaded: (event.tempData ?? state.tempData) != null,
      );
    }

    if (event is DataErrorEvent) {
      yield AppDataState(
        profileData: state.profileData,
        tempData: state.tempData,
        manualData: state.manualData,
        collData: state.collData,
        collFailed: state.collData == null,
        manualFailed: state.manualData == null,
        tempFailed: state.tempData == null,
        profileFailed: state.profileData == null,
        profileLoaded: state.profileData != null,
        tempLoaded: state.tempData != null,
      );
    }
  }

  @override
  Future<void> close() async {
    timer.cancel();
    return super.close();
  }

  _fetchData() async {
    fetching = true;
    try {
      if (!await isConnected()) {
        add(const DataErrorEvent());
        return;
      }

      final uploadingP = uploadingProfile;
      final uploadingM = uploadingManual;

      final http.Response res = await http.get(Uri.parse(urls.kDataUrl));
      final content = jsonDecode(res.body);

      add(_parseContent(content, uploadingP, uploadingM));
    } catch (e, s) {
      developer.log([e, s].toString());
      add(const DataErrorEvent());
    }
    fetching = false;
  }

  _parseContent(content, uploadingProfile, uploadingManual) {
    List<Series<ChartDataPoint, DateTime>>? collectorData;
    TemperatureStatistics? tempData;
    ProfileState? profileData;
    RpmData? manualData;
    double? kwhData;

    try {
      collectorData = parseChartData(content['realTimeKoll']);
    } catch (e, s) {
      developer.log([e, s].toString());
    }
    try {
      tempData = TemperatureStatistics.fromJson(content['temps']);
    } catch (e, s) {
      developer.log([e, s].toString());
    }
    try {
      if (!uploadingProfile) {
        profileData = parseProfileData(content['profiles']);
      }
    } catch (e, s) {
      developer.log([e, s].toString());
    }
    try {
      if (!uploadingManual) {
        manualData = RpmData.fromJson(content['rpmData']);
      }
    } catch (e, s) {
      developer.log([e, s].toString());
    }

    try {
      kwhData = content['kwh'];
    } catch (e, s) {
      developer.log([e, s].toString());
    }

    return DataUpdateEvent(
      collectorData: collectorData,
      manualData: manualData,
      tempData: tempData,
      profileData: profileData,
      kwhData: kwhData,
    );
  }

  uploadData(data) async {
    if (data is RpmData) {
      add(DataUpdateEvent(manualData: data));

      final url = createManualURL(
        data.rpm1,
        data.rpm2,
        data.enabled,
      );
      uploadingManual = true;
      try {
        await http.get(Uri.parse(url));
      } catch (e, s) {
        developer.log([e, s].toString());
      }
      uploadingManual = false;
    } else if (data is ProfileState) {
      add(DataUpdateEvent(profileData: data));

      final url = createProfileURL(data);
      uploadingProfile = true;

      try {
        await http.get(Uri.parse(url));
      } catch (e, s) {
        developer.log([e, s].toString());
      }
      uploadingProfile = false;
    }
  }
}

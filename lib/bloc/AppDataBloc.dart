import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hokollektor/bloc/DataClasses.dart';
import 'package:hokollektor/chart/ChartLogic.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/URLs.dart' as urls;
import 'package:hokollektor/util/network.dart';
import 'package:http/http.dart' as http;

const reloadAfter = 15;

class AppBloc extends Bloc<DataEvent, AppDataState> {
  Timer timer;
  var kollData, tempData, profileData, manualData;
  bool loaded = false,
      fetching = false,
      uploadingManual = false,
      uploadingProfile = false;

  @override
  AppDataState get initialState {
    if (!loaded) {
      loaded = true;
      _fetchData();
      fetching = true;
      timer = new Timer.periodic(Duration(seconds: reloadAfter), (timer) {
        if (!fetching) _fetchData();
      });
    }

    return AppDataState.init(
      profileData: profileData,
      kollData: kollData,
      tempData: tempData,
      manualData: manualData,
    );
  }

  void reload() {
    if (!fetching) {
      _fetchData();
    }

    dispatch(DataUpdateEvent(
      profileData: profileData,
      kollData: kollData,
      tempData: tempData,
      manualData: manualData,
      reload: true,
    ));
  }

  @override
  Stream<AppDataState> mapEventToState(
      AppDataState state, DataEvent event) async* {
    if (event is DataUpdateEvent) {
      yield AppDataState(
        loading: event.reload,
        profileData: event.profileData ?? profileData,
        tempData: event.tempData ?? tempData,
        manualData: event.manualData ?? manualData,
        kollData: event.kollData ?? kollData,
        profileLoaded: (event.profileData ?? profileData) != null,
        tempLoaded: (event.tempData ?? tempData) != null,
      );
    }

    if (event is DataErrorEvent) {
      yield AppDataState(
        profileData: profileData,
        tempData: tempData,
        manualData: manualData,
        kollData: kollData,
        kollFailed: kollData == null,
        manualFailed: manualData == null,
        tempFailed: tempData == null,
        profileFailed: profileData == null,
        errorMessage: event.message ?? '',
        profileLoaded: profileData != null,
        tempLoaded: tempData != null,
      );
    }
  }

  _fetchData() async {
    fetching = true;
    try {
      if (!await isConnected()) {
        dispatch(DataErrorEvent(message: loc.getText(loc.noInternet)));
        return;
      }

      final http.Response res = await http.get(urls.dataUrl);
      final content = jsonDecode(res.body);

      _parseContent(content);

      dispatch(DataUpdateEvent(
        kollData: kollData,
        manualData: manualData,
        tempData: tempData,
        profileData: profileData,
      ));
    } catch (e) {
      print(e);
      dispatch(DataErrorEvent(message: loc.getText(loc.fetchFailed)));
    }
    fetching = false;
  }

  _parseContent(content) {
    try {
      kollData = parseChartData(content['realTimeKoll']) ?? kollData;
    } catch (e) {
      print(e.toString());
    }
    try {
      tempData = InformationHolder.fromJson(content['temps']) ?? tempData;
    } catch (e) {
      print(e.toString());
    }
    try {
      if (!uploadingProfile)
        profileData = parseProfileData(content['profiles']) ?? profileData;
    } catch (e) {
      print(e.toString());
    }
    try {
      if (!uploadingManual)
        manualData = Rpm.fromJson(content['rpmData']) ?? manualData;
    } catch (e) {
      print(e.toString());
    }
  }

  uploadData(data) async {
    if (data is Rpm) {
      dispatch(DataUpdateEvent(
        kollData: kollData,
        manualData: data,
        tempData: tempData,
        profileData: profileData,
      ));
      final url = createManualURL(
        data.rpm1,
        data.rpm2,
        data.enabled,
      );
      uploadingManual = true;
      try {
        await http.get(url);
      } catch (e) {
        print(e.toString());
      }
      uploadingManual = false;
    } else if (data is profileState) {
      dispatch(DataUpdateEvent(
        kollData: kollData,
        manualData: manualData,
        tempData: tempData,
        profileData: data,
      ));
      final url = createProfileURL(data);
      uploadingProfile = true;
      try {
        await http.get(url);
      } catch (e) {
        print(e.toString());
      }
      uploadingProfile = false;
    }
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hokollektor/bloc/DataClasses.dart';
import 'package:hokollektor/chart/ChartLogic.dart';
import 'package:hokollektor/util/Networking.dart';
import 'package:hokollektor/util/URLs.dart' as urls;
import 'package:http/http.dart' as http;

const reloadAfter = 15;

class AppBloc extends Bloc<DataEvent, AppDataState> {
  Timer timer;
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
    return AppDataState.init();
  }

  void reload() {
    if (!fetching) {
      _fetchData();
    }

    dispatch(DataUpdateEvent(
      reload: true,
    ));
  }

  @override
  Stream<AppDataState> mapEventToState(DataEvent event) async* {
    if (event is DataUpdateEvent) {
      yield AppDataState(
        loading: event.reload,
        profileData: event.profileData ?? currentState?.profileData,
        tempData: event.tempData ?? currentState?.tempData,
        manualData: event.manualData ?? currentState?.manualData,
        kollData: event.kollData ?? currentState?.kollData,
        kwhData: event.kwhData ?? currentState?.kwhData,
        profileLoaded: (event.profileData ?? currentState?.profileData) != null,
        tempLoaded: (event.tempData ?? currentState?.tempData) != null,
      );
    }

    if (event is DataErrorEvent) {
      yield AppDataState(
        profileData: currentState?.profileData,
        tempData: currentState?.tempData,
        manualData: currentState?.manualData,
        kollData: currentState?.kollData,
        kwhFailed: currentState?.kwhData == null,
        kollFailed: currentState?.kollData == null,
        manualFailed: currentState?.manualData == null,
        tempFailed: currentState?.tempData == null,
        profileFailed: currentState?.profileData == null,
        profileLoaded: currentState?.profileData != null,
        tempLoaded: currentState?.tempData != null,
      );
    }
  }

  _fetchData() async {
    fetching = true;
    try {
      if (!await isConnected()) {
        dispatch(DataErrorEvent());
        return;
      }

      final uploadingP = uploadingProfile;
      final uploadingM = uploadingManual;

      final http.Response res = await http.get(urls.dataUrl);
      final content = jsonDecode(res.body);

      dispatch(_parseContent(content, uploadingP, uploadingM));
    } catch (e) {
      print(e);
      dispatch(DataErrorEvent());
    }
    fetching = false;
  }

  _parseContent(content, uploadingProfile, uploadingManual) {
    var kollData, tempData, profileData, manualData, kwhData;

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

    try {
      kwhData = content['kwh'] ?? kwhData;
    } catch (e) {
      print(e.toString());
    }

    return DataUpdateEvent(
      kollData: kollData,
      manualData: manualData,
      tempData: tempData,
      profileData: profileData,
      kwhData: kwhData,
    );
  }

  uploadData(data) async {
    if (data is Rpm) {
      dispatch(DataUpdateEvent(manualData: data));

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
      dispatch(DataUpdateEvent(profileData: data));

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

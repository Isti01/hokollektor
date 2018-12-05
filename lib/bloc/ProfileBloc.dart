import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hokollektor/util/URLs.dart';
import 'package:hokollektor/util/network.dart';
import 'package:http/http.dart' as http;

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  bool completed = false;
  Timer timer;
  bool timerCreated = false;
  bool uploading = false;

  @override
  Stream<ProfileState> mapEventToState(
      ProfileState state, ProfileEvent event) async* {
    if (event.hasError) yield ProfileState.failed(event.error);

    if (!event.initial) _submitProfile(event.newState);

    yield ProfileState(state: event.newState);
  }

  void _submitProfile(profileState state) async {
    uploading = true;

    String url = _createProfileURL(state);

    try {
      await http.get(url);
    } catch (e) {
      print(e);
    }
    uploading = false;
  }

  void _fetchData() async {
    try {
      completed = false;

      if (!(await isConnected())) {
        completed = true;
        if (!uploading) dispatch(ProfileEvent.failed("No Internet Connection"));
        return;
      }

      http.Response connection = await http.get(profileLink);

      String body = connection.body;

      Map<String, dynamic> json = jsonDecode(body);

      int profileNumber = int.parse(json['profile']);

      if (profileNumber == null) {
        dispatch(ProfileEvent.failed("Connection Problem"));
        completed = true;
        return;
      }

      completed = true;
      if (!uploading)
        dispatch(ProfileEvent.init(_getProfileState(profileNumber)));
    } catch (e) {
      print(e.toString());
      if (!uploading) dispatch(ProfileEvent.failed('Connection Error'));
    }
  }

  @override
  ProfileState get initialState {
    _fetchData();
    if (!timerCreated) {
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        if (completed && !uploading) {
          _fetchData();
        }
      });
      timerCreated = true;
    }
    return ProfileState.loading();
  }

  @override
  void dispose() {
    timer.cancel();
  }
}

class ProfileEvent {
  final bool initial;
  final bool hasError;
  final String error;
  final profileState newState;

  ProfileEvent({
    this.initial = false,
    this.newState,
    this.hasError = false,
    this.error = '',
  });

  factory ProfileEvent.failed(String message) => ProfileEvent(
        error: message,
        hasError: true,
      );

  factory ProfileEvent.init(profileState newState) => ProfileEvent(
        initial: true,
        newState: newState,
      );

  @override
  String toString() {
    return "Profile Event "
        "initial: $initial, hasError: $hasError, "
        "${hasError ? "Error Message: $error" : ""} "
        "${newState?.toString() ?? ""}";
  }
}

class ProfileState {
  final bool isLoading;
  final bool hasError;
  final String error;
  final profileState state;

  ProfileState({
    this.isLoading = false,
    this.state,
    this.hasError = false,
    this.error = '',
  });

  factory ProfileState.failed(String error) => ProfileState(
        hasError: true,
        error: error,
        state: null,
      );

  factory ProfileState.loading() => ProfileState(
        isLoading: true,
      );

  @override
  String toString() {
    return "ProfileState: loading: $isLoading, hasError: $hasError, ${state?.toString() ?? ""}";
  }
}

enum profileState {
  optimal,
  minimal,
  maximal,
  manual,
}

int _getProfileNumber(profileState profile) {
  switch (profile) {
    case profileState.optimal:
      return 1;
    case profileState.minimal:
      return 3;
    case profileState.maximal:
      return 2;
    case profileState.manual:
      return 4;
  }
  return 1;
}

profileState _getProfileState(int number) {
  switch (number) {
    case 1:
      return profileState.optimal;
    case 3:
      return profileState.minimal;
    case 2:
      return profileState.maximal;
    case 4:
      return profileState.manual;

    default:
      return profileState.optimal;
  }
}

String _createProfileURL(profileState profile) {
  return ProfileSubmitURL + _getProfileNumber(profile).toString();
}

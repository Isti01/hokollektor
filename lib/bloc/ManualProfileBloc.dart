import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hokollektor/util/URLs.dart';
import 'package:hokollektor/util/network.dart';
import 'package:http/http.dart' as http;

class ManualProfileBloc extends Bloc<ManualEvent, ManualState> {
  bool completed = false;
  bool tickerCreated = false;
  Timer timer;

  @override
  ManualState get initialState {
    _fetchData();

    if (!tickerCreated) {
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        if (completed) {
          _fetchData();
        }
      });
      tickerCreated = true;
    }

    return ManualState.loading();
  }

  @override
  void dispose() {
    timer.cancel();
  }

  @override
  Stream<ManualState> mapEventToState(
      ManualState state, ManualEvent event) async* {
    if (event.hasError) yield ManualState.falied(event.error);

    if (!event.initial) _submitManual(event);

    yield ManualState(
      rpm0: event.rpm0,
      rpm1: event.rpm1,
      enabled: event.enabled,
    );
  }

  void _submitManual(ManualEvent event) async {
    try {
      String url = _createManualURL(
        event.rpm0,
        event.rpm1,
        event.enabled,
      );

      var res = await http.get(url);
    } catch (e) {
      print(e.toString());
    }
  }

  void _fetchData() async {
    try {
      completed = false;

      if (!(await isConnected())) {
        completed = true;
        dispatch(ManualEvent.failed("No Internet Connection"));
        return;
      }

      http.Response connection = await http.get(RpmLink);

      String body = connection.body;

      Map<String, dynamic> json = jsonDecode(body);

      Rpm result = Rpm.fromJson(json);
      completed = true;
      dispatch(ManualEvent.init(
          enabled: result.enabled,
          rpm1: int.parse(result.rpm2),
          rpm0: int.parse(result.rpm1)));
    } catch (e) {
      dispatch(ManualEvent.failed('Connection Error'));
      completed = true;
      print(e);
    }
  }
}

class ManualState {
  String error;
  final bool enabled, hasError, isLoading;
  final int rpm0, rpm1;

  ManualState({
    this.enabled,
    this.rpm0,
    this.rpm1,
    this.hasError = false,
    this.error = '',
    this.isLoading = false,
  });

  factory ManualState.falied(String message) => ManualState(
        hasError: true,
        error: message,
      );

  factory ManualState.loading() => ManualState(isLoading: true);
}

class ManualEvent {
  final bool initial;
  String error;
  final bool enabled, hasError;
  final int rpm0, rpm1;

  ManualEvent({
    this.initial = false,
    this.enabled,
    this.rpm0,
    this.rpm1,
    this.hasError = false,
    this.error = '',
  });

  factory ManualEvent.failed(String message) => ManualEvent(
        hasError: true,
        error: message,
      );

  factory ManualEvent.init({bool enabled, int rpm0, int rpm1}) => ManualEvent(
        enabled: enabled,
        rpm0: rpm0,
        rpm1: rpm1,
        initial: true,
      );
}

class Rpm {
  bool enabled;
  String rpm1;
  String rpm2;

  Rpm({this.enabled, this.rpm1, this.rpm2});

  Rpm.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
    rpm1 = json['rpm1'];
    rpm2 = json['rpm2'];
  }
}

String _createManualURL(int speed0, int speed1, bool enabled) {
  return RpmSubmitURL +
      "?adat1=${enabled != null && enabled ? 1 : 0}&adat2=$speed0&adat3=$speed1";
}

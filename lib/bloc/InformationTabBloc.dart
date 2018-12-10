import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hokollektor/util/URLs.dart';
import 'package:hokollektor/util/network.dart';
import 'package:http/http.dart' as http;

const reloadAfter = 120;

class InformationBloc extends Bloc<InformationEvent, InformationState> {
  bool finished = false;
  bool timerCreated = false;
  Timer timer;

  @override
  Stream<InformationState> mapEventToState(
      InformationState state, InformationEvent event) async* {
    if (event.hasError) yield InformationState.failed(event.error);

    yield InformationState(data: event.data);
  }

  @override
  InformationState get initialState {
    _fetchData();
    if (!timerCreated) {
      timer = Timer.periodic(Duration(seconds: reloadAfter), (timer) {
        if (finished) _fetchData();
      });
      timerCreated = true;
    }
    return InformationState.loading();
  }

  @override
  void dispose() {
    timer.cancel();
  }

  void _fetchData() async {
    try {
      finished = false;

      bool connected = await isConnected();

      if (!connected) {
        finished = true;
        return;
      }
      http.Response connection = await http.get(InformationURL);

      String body = connection.body;

      Map<String, dynamic> json = jsonDecode(body);

      finished = true;
      dispatch(InformationEvent(data: _parseData(json)));
    } catch (e) {
      print(e.toString());
      dispatch(InformationEvent.failed("Connection Error"));
    }
  }

  InformationHolder _parseData(Map<String, dynamic> json) {
    return InformationHolder.fromJson(json);
  }
}

class InformationEvent {
  final InformationHolder data;
  final bool hasError;
  final String error;

  InformationEvent({
    this.data,
    this.hasError = false,
    this.error = '',
  });

  factory InformationEvent.failed(String message) => InformationEvent(
        hasError: true,
        error: message,
      );
}

class InformationState {
  final InformationHolder data;
  final bool hasError;
  final String error;
  final bool isLoading;

  InformationState({
    this.data,
    this.hasError = false,
    this.error = '',
    this.isLoading = false,
  });

  factory InformationState.loading() => InformationState(
        isLoading: true,
      );

  factory InformationState.failed(String error) => InformationState(
        hasError: true,
        error: error,
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

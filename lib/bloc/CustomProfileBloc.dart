import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hokollektor/util/URLs.dart' as urls;
import 'package:hokollektor/util/network.dart';
import 'package:http/http.dart' as http;

const int minifiedSize = 5;
const int expandedSize = 10;

class CustomProfileBloc extends Bloc<CustomProfileEvent, CustomProfileState> {
  @override
  CustomProfileState get initialState {
    _fetchCustomProfileState();

    return CustomProfileState.init();
  }

  _submitValues(List<int> values) async {
    if (values.length == minifiedSize)
      values = CustomProfileState.transformToExpanded(values);

    try {
      http.Response res;
      if (values.length == minifiedSize)
        res = await http.get(CustomProfile.createLink(values));
      else
        res = await http.get(CustomProfile.createLink(values));

//      print(res.body);
    } catch (e) {
      print(e.toString());
    }
  }

  _fetchCustomProfileState() async {
    try {
      if (!await isConnected()) {
        dispatch(ProfileErrorEvent('No Internet Connection'));
        return;
      }

      http.Response res = await http.get(urls.customProfileURL);

      final json = jsonDecode(res.body);

      final data = CustomProfile.fromJson(json);
      dispatch(ValueChangeEvent(
        newValues: data.values,
        initial: true,
        expanded: true,
      ));
    } catch (e) {
      print(e.toString());
      dispatch(ProfileErrorEvent('Fetch Failed'));
    }
  }

  @override
  Stream<CustomProfileState> mapEventToState(
      CustomProfileState state, CustomProfileEvent event) async* {
    if (event is ProfileErrorEvent) {
      // print('error caught');
      yield CustomProfileState.error(event.message);
    }

    if (event is ValueChangeEvent) {
      //print('updating value');

      if (!event.initial) _submitValues(event.newValues);

      yield CustomProfileState.success(event.newValues,
          expanded: event.expanded);
    }

    if (event is SizeChangedEvent) {
      // print('updating size');
      yield CustomProfileState.success(state.values, expanded: event.expanded);
    }

    // print('Unknown profile event');
  }
}

class CustomProfileState {
  final bool loading, hasError, expanded;
  final List<int> values;
  final String errorMessage;

  CustomProfileState({
    this.expanded = false,
    this.loading = false,
    this.hasError = false,
    this.values = const [],
    this.errorMessage = '',
  });

  factory CustomProfileState.init() => CustomProfileState(loading: true);

  factory CustomProfileState.error([String errorMessage = '']) =>
      CustomProfileState(
        hasError: true,
        errorMessage: errorMessage,
      );

  factory CustomProfileState.success(List<int> values, {bool expanded}) {
    assert(values != null);
    assert(values.length == minifiedSize || values.length == expandedSize);
    List<int> result = values;

    if (expanded) {
      if (values.length == minifiedSize) result = transformToExpanded(values);
    } else {
      if (values.length == expandedSize) result = _transformToMinified(values);
    }

    return CustomProfileState(values: result, expanded: expanded);
  }

  static transformToExpanded(List<int> input) {
    // print(input.length);

    List<int> result = [];

    for (int i = 0; i < input.length; i++) {
      if (i > 0) result.add((input[i - 1] + input[i]) ~/ 2);

      result.add(input[i]);
    }

    if (result.length == expandedSize - 1) result.add(input[input.length - 1]);

    //print('$input => $result');

    return result;
  }

  static _transformToMinified(List<int> values) {
    // print(values.length);
    List<int> result = [];

    for (int i = 1; i < values.length; i += 2)
      result.add((values[i] + values[i - 1]) ~/ 2);

    return result;
  }
}

abstract class CustomProfileEvent {}

class ProfileErrorEvent extends CustomProfileEvent {
  final String message;

  ProfileErrorEvent(this.message);
}

class ValueChangeEvent extends CustomProfileEvent {
  final List<int> newValues;
  final bool expanded, initial;

  ValueChangeEvent({
    this.newValues,
    this.expanded,
    this.initial = false,
  }) : assert(newValues.length == minifiedSize ||
            newValues.length == expandedSize);
}

class SizeChangedEvent extends CustomProfileEvent {
  final bool expanded;

  SizeChangedEvent(this.expanded);
}

class CustomProfile {
  final List<int> values;

  CustomProfile({
    this.values,
  });

  factory CustomProfile.fromJson(Map<String, dynamic> json) =>
      CustomProfile(values: [
        int.parse(json['param1']),
        int.parse(json['param2']),
        int.parse(json['param3']),
        int.parse(json['param4']),
        int.parse(json['param5']),
        int.parse(json['param6']),
        int.parse(json['param7']),
        int.parse(json['param8']),
        int.parse(json['param9']),
        int.parse(json['param10']),
      ]);

  static createLink(List<int> values) {
    return urls.importCustomProfileURL +
        '?'
        'param1=${values[0]}'
        '&param2=${values[1]}'
        '&param3=${values[2]}'
        '&param4=${values[3]}'
        '&param5=${values[4]}'
        '&param6=${values[5]}'
        '&param7=${values[6]}'
        '&param8=${values[7]}'
        '&param9=${values[8]}'
        '&param10=${values[9]}';
  }
}

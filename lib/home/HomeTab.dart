import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/Loading.dart';
import 'package:hokollektor/bloc/InformationTabBloc.dart';
import 'package:hokollektor/bloc/ManualProfileBloc.dart';
import 'package:hokollektor/bloc/ProfileBloc.dart';
import 'package:hokollektor/chart/Chart.dart';
import 'package:hokollektor/util/tabbedBackdrop.dart';

const fontColor = Colors.white;
const radioActiveColor = Colors.white;
const progressIndicatorColor = AlwaysStoppedAnimation(Colors.white);

class HomeBackpanel extends StatelessWidget {
  final ManualProfileBloc manualBloc;
  final ProfileBloc profileBloc;

  const HomeBackpanel({Key key, this.manualBloc, this.profileBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        BlocBuilder<ProfileEvent, ProfileState>(
          bloc: profileBloc,
          builder: _buildProfile,
        ),
        BlocBuilder<ManualEvent, ManualState>(
          bloc: manualBloc,
          builder: _buildManual,
        ),
      ],
    );
  }

  Widget _buildManual(BuildContext context, ManualState state) {
    final theme = Theme.of(context);

    if (state.isLoading) return Container();

    if (state.hasError)
      return Center(
          child: Text(
        state.error,
        style: theme.textTheme.title.copyWith(color: fontColor),
      ));

    return state.rpm1 != null
        ? _buildCategoryTile(
            theme: theme,
            title: "Manual Configuration",
            children: [
              ManualSlider(
                sliderLabel: 'Ventilator #0',
                initialValue: state.rpm0,
                onChanged: (value) => manualBloc.dispatch(
                      ManualEvent(
                        enabled: state.enabled,
                        rpm0: value,
                        rpm1: state.rpm1,
                      ),
                    ),
              ),
              ManualSlider(
                sliderLabel: 'Ventilator #1',
                initialValue: state.rpm1,
                onChanged: (value) => manualBloc.dispatch(
                      ManualEvent(
                        enabled: state.enabled,
                        rpm0: state.rpm0,
                        rpm1: value,
                      ),
                    ),
              ),
            ],
          )
        : Container();
  }

  Widget _buildProfile(BuildContext context, ProfileState state) {
    final theme = Theme.of(context);

    bool error = !state.isLoading && state.state?.index == null;

    if (state.isLoading)
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CollectorProgressIndicator(
              // valueColor: progressIndicatorColor,
              ),
        ),
      );

    if (state.hasError || error)
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            state.error ?? 'Failed to load!',
            style: theme.textTheme.title.copyWith(color: fontColor),
          ),
        ),
      );

    return Theme(
      data: theme.copyWith(unselectedWidgetColor: Colors.white),
      child: _buildCategoryTile(
        theme: theme,
        title: "Profiles",
        initiallyExpanded: true,
        children: [
          _radioTile('Optimal', profileState.optimal, theme.textTheme, state),
          _radioTile('Minimal', profileState.minimal, theme.textTheme, state),
          _radioTile('Maximal', profileState.maximal, theme.textTheme, state),
          _radioTile('Manual', profileState.manual, theme.textTheme, state),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    List<Widget> children,
    String title,
    ThemeData theme,
    bool initiallyExpanded = false,
  }) {
    return ListTileTheme(
      iconColor: fontColor,
      child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          children: children,
          title: Text(
            title,
            style: theme.textTheme.title.copyWith(
                fontSize: theme.textTheme.title.fontSize + 6.0,
                color: fontColor),
          )),
    );
  }

  _radioTile(
      String text, profileState value, TextTheme theme, ProfileState state) {
    return RadioListTile<profileState>(
      activeColor: radioActiveColor,
//      subtitle: Padding(
//        padding: const EdgeInsets.all(4.0),
//        child: Text(
//          'subtitlesubtitlesubtitlesubtitlesubtitlesubtitlesubtitlesubtitlesubtitlesubtitlesubtitle',
//          style: theme.body2.copyWith(color: fontColor),
//        ),
//      ),

      title: Text(text, style: theme.title.copyWith(color: fontColor)),
      value: value,
      groupValue: state.state,
      onChanged: (profileState value) {
        profileBloc.dispatch(ProfileEvent(newState: value));
      },
    );
  }
}

class HomeFront extends StatelessWidget {
  final InformationBloc bloc;

  const HomeFront({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: kFrontHeadingHeight),
        InformationCards(
          bloc: bloc,
        ),
        Card(
          elevation: 0.0,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: RealTimeChart(
              height: 400.0,
            ),
          ),
        ),
      ],
    );
  }
}

class InformationCards extends StatelessWidget {
  final InformationBloc bloc;

  const InformationCards({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InformationEvent, InformationState>(
      bloc: bloc,
      builder: _buildCards,
    );
  }

  Widget _buildCards(BuildContext context, InformationState state) {
    final theme = Theme.of(context);

    if (!state.hasError && !state.isLoading && state.data != null) {
      InformationHolder data = state.data;

      return Card(
        elevation: 0.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Collector', style: theme.textTheme.title),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Min Temperature: ${data.legkisebbKoll}°C',
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    'Max Temperature: ${data.legnagyobbKoll}°C',
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('House', style: theme.textTheme.title),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    'Min Temperature: ${data.legkisebbBenti}°C',
                    style: theme.textTheme.subhead.copyWith(),
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text(
                    'Max Temperature: ${data.legnagyobbBenti}°C',
                    style: theme.textTheme.subhead.copyWith(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (state.isLoading) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: CollectorProgressIndicator(),
      ));
    } else {
      return Card(
        elevation: 0.0,
        child: InkWell(
          onTap: () => print('asd'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Failed to Load',
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class ManualSlider extends StatefulWidget {
  final String sliderLabel;
  final Function(int value) onChanged;
  final int initialValue;

  const ManualSlider({
    Key key,
    this.onChanged,
    this.initialValue,
    this.sliderLabel,
  }) : super(key: key);

  @override
  _ManualSliderState createState() => _ManualSliderState();
}

class _ManualSliderState extends State<ManualSlider> {
  int value;

  double sliderValue;

  @override
  void initState() {
    super.initState();
    sliderValue = ((widget.initialValue ?? 0) / 100).toDouble();

    if (sliderValue < 0) {
      sliderValue = 0.0;
    }
    if (sliderValue > 1) {
      sliderValue = 1.0;
    }

    value = widget.initialValue ?? 0;
  }

  _setValue(dynamic value) {
    this.value = (value * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              widget.sliderLabel,
              style: theme.body2.copyWith(
                fontSize: theme.body2.fontSize + 3,
                color: fontColor,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                value.toString(),
                style: theme.body2.copyWith(color: fontColor),
              ),
              Expanded(
                child: Slider(
                  inactiveColor: Colors.grey[500],
                  activeColor: Colors.white,
                  value: sliderValue,
                  onChanged: (value) => this.setState(() {
                        _setValue(value);
                        this.sliderValue = value;
                      }),
                  onChangeEnd: (value) {
                    widget.onChanged((value * 100).round());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/Localization.dart' as loc;
import 'package:hokollektor/bloc/AppDataBloc.dart';
import 'package:hokollektor/bloc/CustomProfileBloc.dart';
import 'package:hokollektor/bloc/DataClasses.dart';
import 'package:hokollektor/chart/Chart.dart';
import 'package:hokollektor/home/Home.dart';
import 'package:hokollektor/main.dart';
import 'package:hokollektor/presentation/Presentation.dart';
import 'package:hokollektor/util/TabbedBackdrop.dart';
import 'package:hokollektor/util/custom_profile_picker/CustomProfilePicker.dart';

const fontColor = Colors.white;
const radioActiveColor = Colors.white;
const progressIndicatorColor = AlwaysStoppedAnimation(Colors.white);
const backpanelIndicator =
    CircularProgressIndicator(valueColor: progressIndicatorColor);

class HomeBackpanel extends StatelessWidget {
  final AppBloc bloc;

  const HomeBackpanel({
    Key key,
    this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: [
        inGuestMode
            ? SizedBox()
            : BlocBuilder<DataEvent, AppDataState>(
                bloc: bloc,
                builder: _buildProfile,
              ),
        inGuestMode
            ? SizedBox()
            : BlocBuilder<DataEvent, AppDataState>(
                bloc: bloc,
                builder: _buildManual,
              ),
        LanguageSetting(),
        SizedBox(height: 1000),
        Material(
          type: MaterialType.transparency,
          child: ListTile(
            title: Text(
              loc.getText(loc.presentationTime),
              textAlign: TextAlign.center,
              style:
                  Theme.of(context).textTheme.title.copyWith(color: fontColor),
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => PresentationPage())),
          ),
        ),
        const SizedBox(
          height: kFrontClosedHeight,
        ),
      ],
    );
  }

  Widget _buildManual(BuildContext context, AppDataState state) {
    final theme = Theme.of(context);

    if (state.manualData == null) {
      if (state.loading && state.profileLoaded)
        return const Center(child: backpanelIndicator);
      else if (state.loading) return const SizedBox();
    }
    if ((state.manualFailed || state.manualData == null) &&
        !state.profileFailed)
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: bloc.reload,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                loc.getText(loc.tapToReload),
                style: theme.textTheme.title.copyWith(color: fontColor),
              ),
            ),
          ),
        ),
      );
    else if (state.manualFailed || state.manualData == null)
      return const SizedBox();

    final data = state.manualData;

    return data.rpm2 != null
        ? buildFrame(
            theme: theme,
            title: loc.getText(loc.manualConf),
            children: [
              ManualSlider(
                sliderLabel: loc.getText(loc.vent0),
                initialValue: data.rpm1,
                onChanged: (value) => bloc.uploadData(Rpm(
                      enabled: data.enabled,
                      rpm1: value,
                      rpm2: data.rpm2,
                    )),
              ),
              ManualSlider(
                sliderLabel: loc.getText(loc.vent1),
                initialValue: data.rpm2,
                onChanged: (value) => bloc.uploadData(Rpm(
                      enabled: data.enabled,
                      rpm1: data.rpm1,
                      rpm2: value,
                    )),
              ),
            ],
          )
        : const SizedBox();
  }

  void _customProfileTileClicked(
      profileState value, context, AppDataState state) async {
    final CustomProfileBloc customProfileBloc = CustomProfileBloc();

    final data = state.profileData;

    final result = await showDialog(
      context: context,
      builder: (context) => CustomProfilePicker(bloc: customProfileBloc),
    );

    customProfileBloc.dispose();
    if (result != null && result) {
      if (value != data) {
        bloc.uploadData(value);
      }
    }
  }

  Widget _buildProfile(BuildContext context, AppDataState state) {
    final theme = Theme.of(context);

    final data = state.profileData;

    bool error = !state.loading && data?.index == null;

    if (state.loading && state.profileData == null)
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: backpanelIndicator,
        ),
      );

    if (state.profileFailed || error)
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: bloc.reload,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                loc.getText(loc.tapToReload),
                style: theme.textTheme.title.copyWith(color: fontColor),
              ),
            ),
          ),
        ),
      );

    return buildFrame(
      theme: theme,
      title: loc.getText(loc.profiles),
      initiallyExpanded: true,
      children: [
        _radioTile(
          loc.getText(loc.optimal),
          loc.getText(loc.profileOptimalDescription),
          profileState.optimal,
          theme.textTheme,
          state,
        ),
        _radioTile(
          loc.getText(loc.minimal),
          loc.getText(loc.profileMinimalDescription),
          profileState.minimal,
          theme.textTheme,
          state,
        ),
        _radioTile(
          loc.getText(loc.maximal),
          loc.getText(loc.profileMaximalDescription),
          profileState.maximal,
          theme.textTheme,
          state,
        ),
        _radioTile(
          loc.getText(loc.manual),
          loc.getText(loc.profileManualDescription),
          profileState.manual,
          theme.textTheme,
          state,
        ),
        _radioTile(
          loc.getText(loc.custom),
          loc.getText(loc.profileCustomDescription),
          profileState.custom,
          theme.textTheme,
          state,
          (value) => _customProfileTileClicked(value, context, state),
        ),
      ],
    );
  }

  _radioTile(
    String text,
    String description,
    profileState value,
    TextTheme theme,
    AppDataState state, [
    Function(profileState value) onChanged,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RadioListTile<profileState>(
        activeColor: radioActiveColor,
        title: Text(
          text,
          style: theme.title.copyWith(color: fontColor),
        ),
        subtitle: Text(
          description,
          style: theme.subtitle.copyWith(color: fontColor),
        ),
        value: value,
        groupValue: state.profileData,
        onChanged: (profileState value) {
          if (onChanged != null) {
            onChanged(value);
          } else {
            bloc.uploadData(value);
          }
        },
      ),
    );
  }
}

class HomeFront extends StatelessWidget {
  final AppBloc bloc;
  final title = loc.getText(loc.realtimeChart);

  HomeFront({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: kFrontHeadingHeight),
        InformationCards(
          bloc: bloc,
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RealTimeChart(
                bloc: bloc,
                height: 450,
                title: loc.getText(loc.realtimeChart),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InformationCards extends StatelessWidget {
  final AppBloc bloc;

  const InformationCards({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DataEvent, AppDataState>(
      bloc: bloc,
      builder: _buildCards,
    );
  }

  Widget _buildCards(BuildContext context, AppDataState state) {
    final theme = Theme.of(context);

    if (state.tempData != null && state.kwhData != null) {
      InformationHolder data = state.tempData;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(loc.getText(loc.koll), style: theme.textTheme.title),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  loc.getText(loc.minTemp) + '${data.legkisebbKoll}°C',
                  style: theme.textTheme.subhead.copyWith(),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  loc.getText(loc.maxTemp) + '${data.legnagyobbKoll}°C',
                  style: theme.textTheme.subhead.copyWith(),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  loc.getText(loc.kwhText) + '${state.kwhData}KWh',
                  style: theme.textTheme.subhead.copyWith(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(loc.getText(loc.house), style: theme.textTheme.title),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  loc.getText(loc.minTemp) + '${data.legkisebbBenti}°C',
                  style: theme.textTheme.subhead.copyWith(),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  loc.getText(loc.maxTemp) + '${data.legnagyobbBenti}°C',
                  style: theme.textTheme.subhead.copyWith(),
                ),
              ],
            ),
          ),
          Divider(),
        ],
      );
    } else if (state.loading) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: CircularProgressIndicator(),
      ));
    } else {
      return Card(
        elevation: 0,
        child: InkWell(
          onTap: bloc.reload,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  loc.getText(loc.tapToReload),
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
      sliderValue = 0;
    }
    if (sliderValue > 1) {
      sliderValue = 1;
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
        horizontal: 12,
        vertical: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
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

class LanguageSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
          onTap: () => showDialog(
              context: context,
              builder: (context) => Theme(
                    data: Theme.of(context),
                    child: LanguageDialog(),
                  )),
          title: Text(
            loc.getText(loc.changeLanguage),
            style: theme.textTheme.title.copyWith(
              fontSize: theme.textTheme.title.fontSize + 6,
              color: fontColor,
            ),
          )),
    );
  }
}

class LanguageDialog extends StatefulWidget {
  @override
  _LanguageDialogState createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  List<DropdownMenuItem<String>> languages;
  String chosenValue;

  _initLangs(List<String> langs) => this.languages = langs
      .map((lang) => DropdownMenuItem<String>(
            value: lang,
            child: Center(
              child: Text(loc.languageToOption(lang)),
            ),
          ))
      .toList();

  @override
  void initState() {
    super.initState();
    final langs = loc.getLanguageOptions();

    chosenValue = loc.getPreferredLanguage();

    _initLangs(langs);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: appBorderRadius),
        child: Padding(
          padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  loc.getText(loc.changeLanguage),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.title,
                ),
                SizedBox(height: 12),
                DropdownButton<String>(
                  items: languages,
                  onChanged: (newValue) =>
                      this.setState(() => chosenValue = newValue),
                  value: chosenValue,
                  isExpanded: true,
                ),
                ButtonBar(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlineButton(
                      borderSide: BorderSide(color: theme.primaryColor),
                      shape:
                          RoundedRectangleBorder(borderRadius: appBorderRadius),
                      child: Text(
                        loc.getText(loc.cancel),
                        style: theme.textTheme.button
                            .copyWith(color: theme.primaryColor),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    RaisedButton(
                      color: theme.primaryColor,
                      shape:
                          RoundedRectangleBorder(borderRadius: appBorderRadius),
                      child: Text(
                        loc.getText(loc.save),
                        style:
                            theme.textTheme.button.copyWith(color: fontColor),
                      ),
                      onPressed: () async {
                        await saveLanguagePreference(chosenValue);
                        Navigator.pop(context);
                        loc.onLocaleChange();
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

buildFrame({
  List<Widget> children,
  String title,
  ThemeData theme,
  bool initiallyExpanded = false,
}) {
  return Theme(
      data: theme.copyWith(unselectedWidgetColor: Colors.white),
      child: ListTileTheme(
        iconColor: fontColor,
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          children: children,
          title: Text(
            title,
            style: theme.textTheme.title.copyWith(
              fontSize: theme.textTheme.title.fontSize + 6,
              color: fontColor,
            ),
          ),
        ),
      ));
}

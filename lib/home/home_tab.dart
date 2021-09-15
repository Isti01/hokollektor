import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/bloc/app_data_bloc.dart';
import 'package:hokollektor/bloc/custom_profile_bloc.dart';
import 'package:hokollektor/bloc/data_classes.dart';
import 'package:hokollektor/chart/chart.dart';
import 'package:hokollektor/home/home.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/main.dart';
import 'package:hokollektor/presentation/presentation.dart';
import 'package:hokollektor/util/custom_profile_picker/custom_profile_picker.dart';
import 'package:hokollektor/util/tabbed_backdrop.dart';

const fontColor = Colors.white;
const radioActiveColor = Colors.white;
const progressIndicatorColor = AlwaysStoppedAnimation(Colors.white);
const backPanelIndicator =
    CircularProgressIndicator(valueColor: progressIndicatorColor);

class HomeBackPanel extends StatelessWidget {
  final AppBloc bloc;

  const HomeBackPanel({
    Key key,
    this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        inGuestMode
            ? const SizedBox()
            : BlocBuilder<AppBloc, AppDataState>(
                bloc: bloc,
                builder: _buildProfile,
              ),
        inGuestMode
            ? const SizedBox()
            : BlocBuilder<AppBloc, AppDataState>(
                bloc: bloc,
                builder: _buildManual,
              ),
        const LanguageSetting(),
        const SizedBox(height: 1000),
        Material(
          type: MaterialType.transparency,
          child: ListTile(
            title: Text(
              loc.getText(loc.presentationTime),
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: fontColor),
            ),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PresentationPage())),
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
      if (state.loading && state.profileLoaded) {
        return const Center(child: backPanelIndicator);
      } else if (state.loading) {
        return const SizedBox();
      }
    }
    if ((state.manualFailed || state.manualData == null) &&
        !state.profileFailed) {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: bloc.reload,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                loc.getText(loc.tapToReload),
                style: theme.textTheme.headline6.copyWith(color: fontColor),
              ),
            ),
          ),
        ),
      );
    } else if (state.manualFailed || state.manualData == null) {
      return const SizedBox();
    }

    final data = state.manualData;

    return data.rpm2 != null
        ? buildFrame(
            theme: theme,
            title: loc.getText(loc.manualConf),
            children: [
              ManualSlider(
                sliderLabel: loc.getText(loc.vent0),
                initialValue: data.rpm1,
                onChanged: (value) => bloc.uploadData(RpmData(
                  enabled: data.enabled,
                  rpm1: value,
                  rpm2: data.rpm2,
                )),
              ),
              ManualSlider(
                sliderLabel: loc.getText(loc.vent1),
                initialValue: data.rpm2,
                onChanged: (value) => bloc.uploadData(RpmData(
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
      ProfileState value, context, AppDataState state) async {
    final CustomProfileBloc customProfileBloc = CustomProfileBloc();

    final data = state.profileData;

    final result = await showDialog(
      context: context,
      builder: (context) => CustomProfilePicker(bloc: customProfileBloc),
    );

    await customProfileBloc.close();
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

    if (state.loading && state.profileData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: backPanelIndicator,
        ),
      );
    }

    if (state.profileFailed || error) {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: bloc.reload,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                loc.getText(loc.tapToReload),
                style: theme.textTheme.headline6.copyWith(color: fontColor),
              ),
            ),
          ),
        ),
      );
    }

    return buildFrame(
      theme: theme,
      title: loc.getText(loc.profiles),
      initiallyExpanded: true,
      children: [
        _radioTile(
          loc.getText(loc.optimal),
          loc.getText(loc.profileOptimalDescription),
          ProfileState.optimal,
          theme.textTheme,
          state,
        ),
        _radioTile(
          loc.getText(loc.minimal),
          loc.getText(loc.profileMinimalDescription),
          ProfileState.minimal,
          theme.textTheme,
          state,
        ),
        _radioTile(
          loc.getText(loc.maximal),
          loc.getText(loc.profileMaximalDescription),
          ProfileState.maximal,
          theme.textTheme,
          state,
        ),
        _radioTile(
          loc.getText(loc.manual),
          loc.getText(loc.profileManualDescription),
          ProfileState.manual,
          theme.textTheme,
          state,
        ),
        _radioTile(
          loc.getText(loc.custom),
          loc.getText(loc.profileCustomDescription),
          ProfileState.custom,
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
    ProfileState value,
    TextTheme theme,
    AppDataState state, [
    Function(ProfileState value) onChanged,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RadioListTile<ProfileState>(
        activeColor: radioActiveColor,
        title: Text(
          text,
          style: theme.headline6.copyWith(color: fontColor),
        ),
        subtitle: Text(
          description,
          style: theme.subtitle2.copyWith(color: fontColor),
        ),
        value: value,
        groupValue: state.profileData,
        onChanged: (ProfileState value) {
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
    return BlocBuilder<AppBloc, AppDataState>(
      bloc: bloc,
      builder: _buildCards,
    );
  }

  Widget _buildCards(BuildContext context, AppDataState state) {
    final theme = Theme.of(context);

    if (state.tempData != null && state.kwhData != null) {
      TemperatureStatistics data = state.tempData;

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
                Text(loc.getText(loc.koll), style: theme.textTheme.headline6),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  loc.getText(loc.minTemp) + '${data.minCollector}°C',
                  style: theme.textTheme.subtitle1.copyWith(),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  loc.getText(loc.maxTemp) + '${data.maxCollector}°C',
                  style: theme.textTheme.subtitle1.copyWith(),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  loc.getText(loc.kwhText) + '${state.kwhData}KWh',
                  style: theme.textTheme.subtitle1.copyWith(),
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
                Text(loc.getText(loc.house), style: theme.textTheme.headline6),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  loc.getText(loc.minTemp) + '${data.minHouse}°C',
                  style: theme.textTheme.subtitle1.copyWith(),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  loc.getText(loc.maxTemp) + '${data.maxHouse}°C',
                  style: theme.textTheme.subtitle1.copyWith(),
                ),
              ],
            ),
          ),
          const Divider(),
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
              style: theme.bodyText1.copyWith(
                fontSize: theme.bodyText1.fontSize + 3,
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
                style: theme.bodyText1.copyWith(color: fontColor),
              ),
              Expanded(
                child: Slider(
                  inactiveColor: Colors.grey[500],
                  activeColor: Colors.white,
                  value: sliderValue,
                  onChanged: (value) => setState(() {
                    _setValue(value);
                    sliderValue = value;
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
  const LanguageSetting({Key key}) : super(key: key);

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
                    child: const LanguageDialog(),
                  )),
          title: Text(
            loc.getText(loc.changeLanguage),
            style: theme.textTheme.headline6.copyWith(
              fontSize: theme.textTheme.headline6.fontSize + 6,
              color: fontColor,
            ),
          )),
    );
  }
}

class LanguageDialog extends StatefulWidget {
  const LanguageDialog({Key key}) : super(key: key);

  @override
  _LanguageDialogState createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  List<DropdownMenuItem<String>> locales;
  String chosenValue;

  _initLocales(List<String> locales) {
    this.locales = locales
        .map((locale) => DropdownMenuItem<String>(
              value: locale,
              child: Center(
                child: Text(loc.languageToOption(locale)),
              ),
            ))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    final locales = loc.getLanguageOptions();

    chosenValue = loc.getPreferredLanguage();

    _initLocales(locales);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Material(
        shape: const RoundedRectangleBorder(borderRadius: kAppBorderRadius),
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
                  style: theme.textTheme.headline6,
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  items: locales,
                  onChanged: (newValue) =>
                      setState(() => chosenValue = newValue),
                  value: chosenValue,
                  isExpanded: true,
                ),
                ButtonBar(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlineButton(
                      borderSide: BorderSide(color: theme.primaryColor),
                      shape: const RoundedRectangleBorder(
                          borderRadius: kAppBorderRadius),
                      child: Text(
                        loc.getText(loc.cancel),
                        style: theme.textTheme.button
                            .copyWith(color: theme.primaryColor),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    RaisedButton(
                      color: theme.primaryColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: kAppBorderRadius),
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
            style: theme.textTheme.headline6.copyWith(
              fontSize: theme.textTheme.headline6.fontSize + 6,
              color: fontColor,
            ),
          ),
        ),
      ));
}

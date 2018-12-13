import 'package:flutter/material.dart';
import 'package:hokollektor/bloc/AppDataBloc.dart';
import 'package:hokollektor/bloc/ChartTabBloc.dart';
import 'package:hokollektor/home/ChartTab.dart';
import 'package:hokollektor/home/HomeTab.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/SimpleScrollBehavior.dart';
import 'package:hokollektor/util/tabbedBackdrop.dart';

const HomePanelColor = Colors.blue;
const ChartPanelColor = Colors.teal;

class HomePage extends StatelessWidget {
  final GlobalKey<TabbedBackdropState> backdropKey =
      GlobalKey(debugLabel: "Backdrop Key In Home");

  final ChartTabBloc chartBloc = ChartTabBloc();
  final AppBloc appBloc = AppBloc();

  @override
  Widget build(BuildContext context) {
    loc.initLocale(Localizations.localeOf(context).languageCode);
    return ScrollConfiguration(
      behavior: SimpleScrollBehavior(),
      child: Scaffold(
        body: TabbedBackdrop(
          key: backdropKey,
          tabs: [
            Tab(text: loc.getText(loc.home)),
            Tab(text: loc.getText(loc.charts)),
          ],
          backdrops: [
            BackdropComponent(
              // frontPadding: 12.0,
              frontLayer: HomeFront(
                bloc: appBloc,
              ),
              frontHeading: Text(loc.getText(loc.configureHeader)),
              backLayer: HomeBackpanel(
                bloc: appBloc,
              ),
              backgroundColor: HomePanelColor,
            ),
            BackdropComponent(
              // frontPadding: 12.0,
              frontLayer: ChartFront(
                realTimeBloc: appBloc,
                bloc: chartBloc,
              ),
              frontHeading: Text(loc.getText(loc.chartHeader)),
              backLayer: ChartBackpanel(
                bloc: chartBloc,
                onReturn: _toggleBackdrop,
              ),
              backgroundColor: ChartPanelColor,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBackdrop() {
    backdropKey.currentState.toggleFrontLayer();
  }
}

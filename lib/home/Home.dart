import 'package:flutter/material.dart';
import 'package:hokollektor/HokollektorApp.dart';
import 'package:hokollektor/Localization.dart' as loc;
import 'package:hokollektor/bloc/AppDataBloc.dart';
import 'package:hokollektor/bloc/ChartTabBloc.dart';
import 'package:hokollektor/home/ChartTab.dart';
import 'package:hokollektor/home/HomeTab.dart';
import 'package:hokollektor/util/TabbedBackdrop.dart';

const HomePanelColor = Colors.blue;
const ChartPanelColor = Colors.teal;
const appBorderRadius = BorderRadius.all(Radius.circular(12));

class HomePage extends StatelessWidget {
  final GlobalKey<TabbedBackdropState> backdropKey =
      GlobalKey(debugLabel: "Backdrop Key In Home");

  final ChartTabBloc chartBloc = ChartTabBloc();
  final AppBloc appBloc = AppBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabbedBackdrop(
        key: backdropKey,
        tabs: [
          Tab(text: loc.getText(loc.home)),
          Tab(text: loc.getText(loc.charts)),
        ],
        backdrops: [
          BackdropComponent(
            // frontPadding: 12,
            frontLayer: Theme(
              data: ThemeData(
                primarySwatch: HomePanelColor,
                fontFamily: AppFontFamily,
              ),
              child: HomeFront(bloc: appBloc),
            ),
            frontHeading: Text(loc.getText(loc.configureHeader)),
            backLayer: Theme(
              data: ThemeData(
                primarySwatch: HomePanelColor,
                fontFamily: AppFontFamily,
              ),
              child: HomeBackpanel(bloc: appBloc),
            ),
            backgroundColor: HomePanelColor,
          ),
          BackdropComponent(
            // frontPadding: 12,
            frontLayer: Theme(
              data: ThemeData(
                primarySwatch: ChartPanelColor,
                fontFamily: AppFontFamily,
              ),
              child: ChartFront(realTimeBloc: appBloc, bloc: chartBloc),
            ),
            frontHeading: Text(loc.getText(loc.chartHeader)),
            backLayer: Theme(
              data: ThemeData(
                primarySwatch: ChartPanelColor,
                fontFamily: AppFontFamily,
              ),
              child: ChartBackpanel(bloc: chartBloc, onReturn: _toggleBackdrop),
            ),
            backgroundColor: ChartPanelColor,
          ),
        ],
      ),
    );
  }

  void _toggleBackdrop() {
    backdropKey.currentState.toggleFrontLayer();
  }
}

import 'package:flutter/material.dart';
import 'package:hokollektor/bloc/app_data_bloc.dart';
import 'package:hokollektor/bloc/chart_tab_bloc.dart';
import 'package:hokollektor/collector_app.dart';
import 'package:hokollektor/home/chart_tab.dart';
import 'package:hokollektor/home/home_tab.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/tabbed_backdrop.dart';

const kHomePanelColor = Colors.blue;
const kChartPanelColor = Colors.teal;
const kAppBorderRadius = BorderRadius.all(Radius.circular(12));

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            frontLayer: Theme(
              data: ThemeData(
                primarySwatch: kHomePanelColor,
                fontFamily: kAppFontFamily,
              ),
              child: HomeFront(bloc: appBloc),
            ),
            frontHeading: Text(loc.getText(loc.configureHeader)),
            backLayer: Theme(
              data: ThemeData(
                primarySwatch: kHomePanelColor,
                fontFamily: kAppFontFamily,
              ),
              child: HomeBackPanel(
                key: UniqueKey(),
                bloc: appBloc,
              ),
            ),
            backgroundColor: kHomePanelColor,
          ),
          BackdropComponent(
            frontLayer: Theme(
              data: ThemeData(
                primarySwatch: kChartPanelColor,
                fontFamily: kAppFontFamily,
              ),
              child: ChartFront(realTimeBloc: appBloc, bloc: chartBloc),
            ),
            frontHeading: Text(loc.getText(loc.chartHeader)),
            backLayer: Theme(
              data: ThemeData(
                primarySwatch: kChartPanelColor,
                fontFamily: kAppFontFamily,
              ),
              child: ChartBackPanel(
                key: UniqueKey(),
                bloc: chartBloc,
                onReturn: _toggleBackdrop,
              ),
            ),
            backgroundColor: kChartPanelColor,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    appBloc.close();
    chartBloc.close();
    super.dispose();
  }

  void _toggleBackdrop() {
    backdropKey.currentState.toggleFrontLayer();
  }
}

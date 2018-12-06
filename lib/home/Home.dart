import 'package:flutter/material.dart';
import 'package:hokollektor/bloc/ChartTabBloc.dart';
import 'package:hokollektor/bloc/InformationTabBloc.dart';
import 'package:hokollektor/bloc/ManualProfileBloc.dart';
import 'package:hokollektor/bloc/ProfileBloc.dart';
import 'package:hokollektor/home/ChartTab.dart';
import 'package:hokollektor/home/HomeTab.dart';
import 'package:hokollektor/util/SimpleScrollBehavior.dart';
import 'package:hokollektor/util/tabbedBackdrop.dart';

const HomePanelColor = Colors.blue;
const ChartPanelColor = Colors.teal;

class HomePage extends StatelessWidget {
  final GlobalKey<TabbedBackdropState> backdropKey =
      GlobalKey(debugLabel: "Backdrop Key In Home");

  final ChartTabBloc chartBloc = ChartTabBloc();
  final InformationBloc informationBloc = InformationBloc();
  final ManualProfileBloc manualBloc = ManualProfileBloc();
  final ProfileBloc profileBloc = ProfileBloc();

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: SimpleScrollBehavior(),
      child: Scaffold(
        body: TabbedBackdrop(
          key: backdropKey,
          tabs: [
            Tab(text: "Home"),
            Tab(text: "Charts"),
          ],
          backdrops: [
            BackdropComponent(
              // frontPadding: 12.0,
              frontLayer: HomeFront(
                bloc: informationBloc,
              ),
              frontHeading: Text('Configure'),
              backLayer: HomeBackpanel(
                manualBloc: manualBloc,
                profileBloc: profileBloc,
              ),
              backgroundColor: HomePanelColor,
            ),
            BackdropComponent(
              // frontPadding: 12.0,
              frontLayer: ChartFront(
                bloc: chartBloc,
              ),
              frontHeading: Text('More Charts'),
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

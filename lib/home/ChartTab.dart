import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/bloc/AppDataBloc.dart';
import 'package:hokollektor/bloc/ChartTabBloc.dart';
import 'package:hokollektor/chart/Chart.dart';
import 'package:hokollektor/chart/datePicker.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/tabbedBackdrop.dart';

class ChartBackpanel extends StatelessWidget {
  final VoidCallback onReturn;
  final Color lineColor;
  final ChartTabBloc bloc;

  const ChartBackpanel({
    Key key,
    this.onReturn,
    this.lineColor = Colors.white,
    this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartEvent, ChartTabState>(
      bloc: bloc,
      builder: _build,
    );
  }

  Widget _build(BuildContext context, ChartTabState state) {
    return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEntry(
                  Charts.weekly, loc.getText(loc.weeklyChart), context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEntry(
                  Charts.daily, loc.getText(loc.dailyChart), context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEntry(
                  Charts.hourly, loc.getText(loc.hourlyChart), context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEntry(Charts.realTime,
                  loc.getText(loc.realtimeChart), context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEntry(
                  Charts.custom, loc.getText(loc.customChart), context, state),
            ),
            const SizedBox(
              height: kFrontClosedHeight,
            ),
          ],
        ));
  }

  Widget _buildEntry(
      Charts chart, String text, BuildContext context, ChartTabState state) {
    Color color = Colors.white;

    var onPressed = () async {
      if (chart == Charts.custom) {
        try {
          final dates = await showDialog(
            context: context,
            builder: (BuildContext context) => DatePickerDialog(),
            barrierDismissible: true,
          );

          DateTime elso = DateTime(
            dates[0].year,
            dates[0].month,
            dates[0].day,
          );

          DateTime masodik = DateTime(
            dates[1].year,
            dates[1].month,
            dates[1].day,
            23,
            59,
          );

          int startDate = elso.millisecondsSinceEpoch ~/ 1000;
          int endDate = masodik.millisecondsSinceEpoch ~/ 1000;

          bloc.dispatch(CustomChartTabEvent(
            Charts.custom,
            startDate,
            endDate,
          ));
        } catch (e) {
          print(e.toString());
        }
      }
      onReturn();
    };

    if (state.chart != chart) {
      onPressed = () async {
        if (chart == Charts.custom) {
          try {
            final dates = await showDialog(
                context: context,
                builder: (BuildContext context) => DatePickerDialog(),
                barrierDismissible: true);

            DateTime elso = DateTime(
              dates[0].year,
              dates[0].month,
              dates[0].day,
            );

            DateTime masodik = DateTime(
              dates[1].year,
              dates[1].month,
              dates[1].day,
              23,
              30,
            );

            int startDate = elso.millisecondsSinceEpoch ~/ 1000;
            int endDate = masodik.millisecondsSinceEpoch ~/ 1000;

            bloc.dispatch(CustomChartTabEvent(
              Charts.custom,
              startDate,
              endDate,
            ));
          } catch (e) {
            print(e.toString());
          }
        } else {
          bloc.dispatch(ChartTabEvent(chart));
        }
        onReturn();
      };
      color = Colors.transparent;
    }

    return RaisedButton(
      elevation: 0.0,
      highlightElevation: 0.0,
      disabledElevation: 0.0,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: color, width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(12.0))),
      color: Colors.transparent,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          text,
          style:
              Theme.of(context).textTheme.title.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class ChartFront extends StatefulWidget {
  final ChartTabBloc bloc;
  final AppBloc realTimeBloc;

  const ChartFront({
    Key key,
    this.bloc,
    this.realTimeBloc,
  })  : assert(bloc != null),
        super(key: key);

  @override
  ChartFrontState createState() {
    return new ChartFrontState();
  }
}

class ChartFrontState extends State<ChartFront> {
  Widget chartWidget;
  String title;
  Charts chart;
  int startDate;
  int endDate;

  @override
  void initState() {
    super.initState();

    chart = initialChart;
    _createWidgets();

    widget.bloc.state.listen((ChartTabState data) {
      this.setState(() {
        this.chart = data.chart;
        this.startDate = data.startDate;
        this.endDate = data.endDate;
        _createWidgets();
      });
    });
  }

  void _createWidgets() {
    this.title = getChartTitle(this.chart);
    this.chartWidget = null;
    this.chartWidget = _getChart(
      chart,
      startDate: startDate,
      endDate: endDate,
      bloc: widget.realTimeBloc,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _build(context);
  }

  Widget _build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: kFrontHeadingHeight),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              this.title,
              style: Theme.of(context).textTheme.title,
            ),
          ),
          this.chartWidget,
        ],
      ),
    );
  }

  String getChartTitle(Charts chart) {
    switch (chart) {
      case Charts.realTime:
        return loc.getText(loc.realtimeChart);
      case Charts.hourly:
        return loc.getText(loc.hourlyChart);
      case Charts.daily:
        return loc.getText(loc.dailyChart);
      case Charts.weekly:
        return loc.getText(loc.weeklyChart);
      case Charts.custom:
        return loc.getText(loc.customChart);
    }
    return '';
  }

  Widget _getChart(
    Charts chart, {
    int startDate,
    int endDate,
    AppBloc bloc,
  }) {
    switch (chart) {
      case Charts.realTime:
        return RealTimeChart(
          bloc: bloc,
          height: 450.0,
        );
      case Charts.hourly:
        return OneHourChart(
          key: UniqueKey(),
          height: 450.0,
        );
      case Charts.daily:
        return OneDayChart(
          key: UniqueKey(),
          height: 450.0,
        );
      case Charts.weekly:
        return OneWeekChart(
          key: UniqueKey(),
          height: 450.0,
        );
      case Charts.custom:
        return new CustomChart(
          key: UniqueKey(),
          height: 450.0,
          startDate: startDate,
          endDate: endDate,
        );
    }
    return const SizedBox();
  }
}

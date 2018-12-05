import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/bloc/ChartTabBloc.dart';
import 'package:hokollektor/chart/Chart.dart';
import 'package:hokollektor/chart/datePicker.dart';
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
    return ListView(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEntry(charts.weekly, "Weekly Chart", context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEntry(charts.daily, "Daily Chart", context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEntry(charts.hourly, "Hourly Chart", context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEntry(
                  charts.realTime, "RealTime Chart", context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildEntry(charts.custom, "Custom Chart", context, state),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildEntry(
      charts chart, String text, BuildContext context, ChartTabState state) {
    Color color = Colors.white;

    var onPressed = () async {
      if (chart == charts.custom) {
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
            charts.custom,
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
        if (chart == charts.custom) {
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
              59,
            );

            int startDate = elso.millisecondsSinceEpoch ~/ 1000;
            int endDate = masodik.millisecondsSinceEpoch ~/ 1000;

            bloc.dispatch(CustomChartTabEvent(
              charts.custom,
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
          borderRadius: BorderRadius.all(Radius.circular(12.0))),
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

  const ChartFront({
    Key key,
    this.bloc,
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
  charts chart;
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
    this.title = _getChartTitle(this.chart);
    this.chartWidget = _getChart(
      chart,
      startDate,
      endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _build(context);
  }

  Widget _build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
      ),
      child: ListView(children: [
        SizedBox(height: kFrontHeadingHeight),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            this.title,
            style: Theme.of(context).textTheme.title,
          ),
        ),
        this.chartWidget,
      ]),
    );
  }

  String _getChartTitle(charts chart) {
    switch (chart) {
      case charts.realTime:
        return 'RealTime Chart';
      case charts.hourly:
        return 'Hourly Chart';
      case charts.daily:
        return 'Daily Chart';
      case charts.weekly:
        return 'Weekly Chart';
      case charts.custom:
        return 'Custom Chart';
    }
    return '';
  }

  Widget _getChart(
    charts chart, [
    int startDate,
    int endDate,
  ]) {
    switch (chart) {
      case charts.realTime:
        return RealTimeChart(
          height: 450.0,
        );
      case charts.hourly:
        return OneHourChart(
          height: 450.0,
        );
      case charts.daily:
        return OneDayChart(
          height: 450.0,
        );
      case charts.weekly:
        return OneWeekChart(
          height: 450.0,
        );
      case charts.custom:
        return CustomChart(
          height: 450.0,
          startDate: startDate,
          endDate: endDate,
        );
        break;
    }
    return Container();
  }
}

//
//final ChartTabBloc bloc;
//
//const ChartFront({
//Key key,
//this.bloc,
//})  : assert(bloc != null),
//super(key: key);
//
//@override
//Widget build(BuildContext context) {
//  return BlocBuilder<ChartTabEvent, ChartTabState>(
//    bloc: bloc,
//    builder: _build,
//  );
//}
//
//Widget _build(BuildContext context, ChartTabState state) {
//  return Padding(
//    padding: const EdgeInsets.only(
//      left: 16.0,
//      right: 16.0,
//      top: 8.0,
//    ),
//    child: ListView(children: [
//      Padding(
//        padding: const EdgeInsets.all(8.0),
//        child: Text(
//          _getChartTitle(state.chart),
//          style: Theme.of(context).textTheme.title,
//        ),
//      ),
//      _getChart(state.chart),
//    ]),
//  );
//}
//
//String _getChartTitle(charts chart) {
//  switch (chart) {
//    case charts.realTime:
//      return 'RealTime Chart';
//    case charts.hourly:
//      return 'Hourly Chart';
//    case charts.daily:
//      return 'Daily Chart';
//    case charts.weekly:
//      return 'Weekly Chart';
//  }
//  return '';
//}
//
//Widget _getChart(charts chart) {
//  switch (chart) {
//    case charts.realTime:
//      return RealTimeChart(
//        height: 450.0,
//      );
//    case charts.hourly:
//      return OneHourChart(
//        height: 450.0,
//      );
//    case charts.daily:
//      return OneDayChart(
//        height: 450.0,
//      );
//    case charts.weekly:
//      return OneWeekChart(
//        height: 450.0,
//      );
//  }
//  return Container();
//}

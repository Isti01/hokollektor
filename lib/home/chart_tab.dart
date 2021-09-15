import "dart:developer" as developer;

import 'package:flutter/material.dart' hide DatePickerDialog;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/bloc/app_data_bloc.dart';
import 'package:hokollektor/bloc/chart_tab_bloc.dart';
import 'package:hokollektor/chart/chart.dart';
import 'package:hokollektor/chart/date_picker.dart';
import 'package:hokollektor/home/home.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/tabbed_backdrop.dart';

class ChartBackPanel extends StatelessWidget {
  final VoidCallback onReturn;
  final Color lineColor;
  final ChartTabBloc bloc;

  const ChartBackPanel({
    Key key,
    this.onReturn,
    this.lineColor = Colors.white,
    this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChartTabBloc, ChartTabState>(
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
              padding: const EdgeInsets.all(8),
              child: _buildEntry(
                  Charts.weekly, loc.getText(loc.weeklyChart), context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildEntry(
                  Charts.daily, loc.getText(loc.dailyChart), context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildEntry(
                  Charts.hourly, loc.getText(loc.hourlyChart), context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildEntry(Charts.realTime,
                  loc.getText(loc.realtimeChart), context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildEntry(
                  Charts.custom, loc.getText(loc.customChart), context, state),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildEntry(
                  Charts.watt, loc.getText(loc.wattChart), context, state),
            ),
            const SizedBox(height: kFrontClosedHeight),
          ],
        ));
  }

  Widget _buildEntry(
      Charts chart, String text, BuildContext context, ChartTabState state) {
    Color color = Colors.white;

    var onPressed = () async {
      if (chart == Charts.custom || chart == Charts.watt) {
        await _showCustomChart(context, chart == Charts.watt);
      }

      onReturn();
    };

    if (state.chart != chart) {
      onPressed = () async {
        if (chart == Charts.custom || chart == Charts.watt) {
          await _showCustomChart(context, chart == Charts.watt);
        } else {
          bloc.add(ChartTabEvent(chart));
        }
        onReturn();
      };
      color = Colors.transparent;
    }

    return RaisedButton(
      elevation: 0,
      highlightElevation: 0,
      disabledElevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 2),
        borderRadius: kAppBorderRadius,
      ),
      color: Colors.transparent,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(color: Colors.white),
        ),
      ),
    );
  }

  _showCustomChart(context, wattChart) async {
    try {
      final List<DateTime> dates = await showDialog(
          context: context,
          builder: (BuildContext context) => const DatePickerDialog(),
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

      bloc.add(CustomChartTabEvent(
        wattChart ? Charts.watt : Charts.custom,
        startDate,
        endDate,
      ));
    } catch (e) {
      developer.log(e.toString());
    }
  }
}

class ChartFront extends StatefulWidget {
  final ChartTabBloc bloc;
  final AppBloc realTimeBloc;

  const ChartFront({
    Key key,
    @required this.bloc,
    this.realTimeBloc,
  })  : assert(bloc != null),
        super(key: key);

  @override
  ChartFrontState createState() => ChartFrontState();
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

    widget.bloc.stream.listen((ChartTabState data) {
      if (mounted) {
        setState(() {
          chart = data.chart;
          startDate = data.startDate;
          endDate = data.endDate;
          _createWidgets();
        });
      } else {
        chart = data.chart;
        startDate = data.startDate;
        endDate = data.endDate;
        _createWidgets();
      }
    });
  }

  void _createWidgets() {
    title = getChartTitle(chart);
    chartWidget = _getChart(
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: kFrontHeadingHeight),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          chartWidget,
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
      case Charts.watt:
        return loc.getText(loc.wattChart);
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
          height: 450,
        );
      case Charts.hourly:
        return OneHourChart(
          key: UniqueKey(),
          height: 450,
        );
      case Charts.daily:
        return OneDayChart(
          key: UniqueKey(),
          height: 450,
        );
      case Charts.weekly:
        return OneWeekChart(
          key: UniqueKey(),
          height: 450,
        );
      case Charts.custom:
        return CustomChart(
          key: UniqueKey(),
          height: 450,
          startDate: startDate,
          endDate: endDate,
        );
      case Charts.watt:
        return WattChart(
          key: UniqueKey(),
          height: 450,
          startDate: startDate,
          endDate: endDate,
        );
    }
    return const SizedBox();
  }
}

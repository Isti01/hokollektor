import "dart:developer" as developer;

import 'package:flutter/material.dart' hide DatePickerDialog;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/bloc/app_data_bloc.dart';
import 'package:hokollektor/bloc/chart_tab_bloc.dart';
import 'package:hokollektor/chart/chart.dart';
import 'package:hokollektor/home/home.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/tabbed_backdrop.dart';

const int kLastDay = 15;
final DateTime kFirstDate = DateTime(2018, 1, 1);
const Duration kMaxInterval = Duration(days: 14);

class ChartBackPanel extends StatelessWidget {
  final VoidCallback onReturn;
  final Color lineColor;
  final ChartTabBloc bloc;

  const ChartBackPanel({
    Key? key,
    required this.onReturn,
    this.lineColor = Colors.white,
    required this.bloc,
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
              .headline6!
              .copyWith(color: Colors.white),
        ),
      ),
    );
  }

  _showCustomChart(context, isWattChart) async {
    try {
      final now = DateTime.now();

      DateTimeRange? range = await showDateRangePicker(
        context: context,
        lastDate: DateTime(now.year, now.month, now.day),
        firstDate: DateTime(now.year, now.month, now.day, 23, 59)
            .subtract(const Duration(days: kLastDay - 1)),
      );

      if (range == null) return;

      DateTime first = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );

      DateTime second = DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
        23,
        59,
      );

      int startDate = first.millisecondsSinceEpoch ~/ 1000;
      int endDate = second.millisecondsSinceEpoch ~/ 1000;

      bloc.add(CustomChartTabEvent(
        isWattChart ? Charts.watt : Charts.custom,
        startDate,
        endDate,
      ));
    } catch (e, s) {
      developer.log([e, s].toString());
    }
  }
}

class ChartFront extends StatefulWidget {
  final ChartTabBloc bloc;
  final AppBloc realTimeBloc;

  const ChartFront({
    Key? key,
    required this.bloc,
    required this.realTimeBloc,
  }) : super(key: key);

  @override
  ChartFrontState createState() => ChartFrontState();
}

class ChartFrontState extends State<ChartFront> {
  late Widget chartWidget;
  late String title;
  late Charts chart;
  int? startDate;
  int? endDate;

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
  }

  Widget _getChart(
    Charts chart, {
    int? startDate,
    int? endDate,
    required AppBloc bloc,
  }) {
    assert((chart != Charts.custom && chart != Charts.watt) ||
        (startDate != null && endDate != null));
    switch (chart) {
      case Charts.realTime:
        return RealTimeChart(
          bloc: bloc,
          height: kChartHeight,
        );
      case Charts.hourly:
        return OneHourChart(
          key: UniqueKey(),
          height: kChartHeight,
        );
      case Charts.daily:
        return OneDayChart(
          key: UniqueKey(),
          height: kChartHeight,
        );
      case Charts.weekly:
        return OneWeekChart(
          key: UniqueKey(),
          height: kChartHeight,
        );
      case Charts.custom:
        return CustomChart(
          key: UniqueKey(),
          height: kChartHeight,
          startDate: startDate!,
          endDate: endDate!,
        );
      case Charts.watt:
        return WattChart(
          key: UniqueKey(),
          height: kChartHeight,
          startDate: startDate!,
          endDate: endDate!,
        );
    }
  }
}

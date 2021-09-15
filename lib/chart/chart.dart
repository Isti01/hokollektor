import 'dart:async';
import "dart:developer" as developer;

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/bloc/app_data_bloc.dart';
import 'package:hokollektor/bloc/data_classes.dart';
import 'package:hokollektor/chart/chart_explanation.dart';
import 'package:hokollektor/chart/chart_logic.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/urls.dart' as urls;

class CollChart extends StatefulWidget {
  final String url;
  final double height;
  final bool animate;
  final bool clickable;
  final bool wattChart;
  final ChartExplanation chartExplanation;

  CollChart({
    Key key,
    @required this.url,
    this.animate = true,
    this.height = 300,
    this.clickable = false,
    this.wattChart = false,
  })  : chartExplanation = ChartExplanation(wattChart: wattChart),
        super(key: key);

  @override
  CollChartState createState() {
    return CollChartState();
  }
}

class CollChartState extends State<CollChart>
    with AutomaticKeepAliveClientMixin {
  bool reloading = false;

  Future<List<charts.Series<ChartDataPoint, DateTime>>> _fetch() async {
    List<charts.Series<ChartDataPoint, DateTime>> data;

    try {
      data = await fetchChartData(widget.url, widget.wattChart);
    } catch (e) {
      developer.log(e.toString());
    }
    reloading = false;
    return data;
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isAnimated = false;
  bool failed = false;

  bool get _animate {
    if (!_isAnimated) {
      _isAnimated = true;
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _fetch(),
      builder: _build,
    );
  }

  Widget _build(BuildContext context, AsyncSnapshot snapshot) {
    bool loaded = !snapshot.hasError && snapshot.hasData;
    return AbsorbPointer(
      absorbing: (!loaded || !widget.clickable) && !snapshot.hasError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.height,
            child: _buildChart(context, snapshot),
          ),
          loaded ? widget.chartExplanation : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData && !reloading) {
      return charts.TimeSeriesChart(
        snapshot.data,
        animate: _animate,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
      );
    } else if (snapshot.hasError && !reloading) {
      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => setState(() {
            reloading = true;
          }),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error),
                Text(loc.getText(loc.failedToLoadChart)),
              ],
            ),
          ),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class PreloadedCollChart extends StatefulWidget {
  final AppBloc bloc;
  final double height;
  final bool animate;
  final bool clickable;
  final chartExplanation = ChartExplanation();
  final String title;

  PreloadedCollChart({
    Key key,
    @required this.bloc,
    this.animate = true,
    this.height = 300,
    this.clickable = false,
    this.title,
  }) : super(key: key);

  @override
  PreloadedCollChartState createState() => PreloadedCollChartState();
}

class PreloadedCollChartState extends State<PreloadedCollChart>
    with AutomaticKeepAliveClientMixin {
  bool _isAnimated = false;
  bool failed = false;

  bool get _animate {
    if (!_isAnimated) {
      _isAnimated = true;
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder(
      bloc: widget.bloc,
      builder: _build,
    );
  }

  Widget _build(BuildContext context, AppDataState snapshot) {
    bool loaded = !snapshot.loading && snapshot.collData != null;
    return AbsorbPointer(
      absorbing: (!loaded || !widget.clickable) && !snapshot.collFailed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.title != null && snapshot.collData != null
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                )
              : const SizedBox(),
          SizedBox(
            height: widget.height,
            child: _buildChart(context, snapshot),
          ),
          loaded ? widget.chartExplanation : const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, AppDataState snapshot) {
    if (snapshot.collData != null) {
      return charts.TimeSeriesChart(
        snapshot.collData,
        animate: _animate,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
      );
    } else if (snapshot.collFailed && !snapshot.tempFailed) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: Material(
              child: InkWell(
                onTap: () => widget.bloc.reload(),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error),
                      Text(loc.getText(loc.failedToLoadChart)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      );
    } else if (snapshot.loading && snapshot.tempLoaded) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return const SizedBox();
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class RealTimeChart extends PreloadedCollChart {
  RealTimeChart({
    Key key,
    @required AppBloc bloc,
    double height,
    String title,
  }) : super(key: key, height: height, bloc: bloc, title: title);
}

class OneDayChart extends CollChart {
  OneDayChart({double height, Key key})
      : super(height: height, url: urls.kOneDayChartURL, key: key);
}

class OneWeekChart extends CollChart {
  OneWeekChart({double height, Key key})
      : super(height: height, url: urls.kOneWeekChartURL, key: key);
}

class OneHourChart extends CollChart {
  OneHourChart({double height, Key key})
      : super(height: height, url: urls.kOneHourChartURL, key: key);
}

class CustomChart extends CollChart {
  CustomChart({double height, int startDate, int endDate, Key key})
      : super(
          key: key,
          height: height,
          url: urls.kCustomChartURL + '?ki=$startDate&vi=$endDate',
        );
}

class WattChart extends CollChart {
  WattChart({double height, int startDate, int endDate, Key key})
      : super(
          key: key,
          height: height,
          url: urls.kWattChartURL + '?ki=$startDate&vi=$endDate',
          wattChart: true,
        );
}

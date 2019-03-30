import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/Localization.dart' as loc;
import 'package:hokollektor/bloc/AppDataBloc.dart';
import 'package:hokollektor/bloc/DataClasses.dart';
import 'package:hokollektor/chart/ChartExplanation.dart';
import 'package:hokollektor/chart/ChartLogic.dart';
import 'package:hokollektor/util/URLs.dart' as urls;

class KollChart extends StatefulWidget {
  final String url;
  final double height;
  final bool animate;
  final bool clickable;
  final bool wattChart;
  final chartExplanation;

  KollChart({
    Key key,
    @required this.url,
    this.animate = true,
    this.height = 300,
    this.clickable = false,
    this.wattChart = false,
  })  : chartExplanation = ChartExplanation(wattChart: wattChart),
        super(key: key);

  @override
  KollChartState createState() {
    return new KollChartState();
  }
}

class KollChartState extends State<KollChart>
    with AutomaticKeepAliveClientMixin {
  bool reloading = false;

  Future<List<charts.Series<ChartDataPoint, DateTime>>> _fetch() async {
    var data;

    try {
      data = await fetchChartData(widget.url, widget.wattChart);
    } catch (e) {
      print(e.toString());
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
          onTap: () => this.setState(() {
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
    } else
      return const Center(child: CircularProgressIndicator());
  }

  @override
  bool get wantKeepAlive => true;
}

class PreloadedKollChart extends StatefulWidget {
  final AppBloc bloc;
  final double height;
  final bool animate;
  final bool clickable;
  final chartExplanation = ChartExplanation();
  final title;

  PreloadedKollChart({
    @required this.bloc,
    this.animate = true,
    this.height = 300,
    this.clickable = false,
    this.title,
  });

  @override
  PreloadedKollChartState createState() {
    return new PreloadedKollChartState();
  }
}

class PreloadedKollChartState extends State<PreloadedKollChart>
    with AutomaticKeepAliveClientMixin {
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
    return BlocBuilder(
      bloc: widget.bloc,
      builder: _build,
    );
  }

  Widget _build(BuildContext context, AppDataState snapshot) {
    bool loaded = !snapshot.loading && snapshot.kollData != null;
    return AbsorbPointer(
      absorbing: (!loaded || !widget.clickable) && !snapshot.kollFailed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.title != null && snapshot.kollData != null
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.title,
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
    if (snapshot.kollData != null) {
      return charts.TimeSeriesChart(
        snapshot.kollData,
        animate: _animate,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
      );
    } else if (snapshot.kollFailed && !snapshot.tempFailed) {
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
          Spacer(),
        ],
      );
    } else if (snapshot.loading && snapshot.tempLoaded)
      return const Center(child: CircularProgressIndicator());
    else
      return const SizedBox();
  }

  @override
  bool get wantKeepAlive => true;
}

class RealTimeChart extends PreloadedKollChart {
  RealTimeChart({
    @required AppBloc bloc,
    double height,
    String title,
  }) : super(height: height, bloc: bloc, title: title);
}

class OneDayChart extends KollChart {
  OneDayChart({double height, Key key})
      : super(height: height, url: urls.OneDayChartURL, key: key);
}

class OneWeekChart extends KollChart {
  OneWeekChart({double height, Key key})
      : super(height: height, url: urls.OneWeekChartURL, key: key);
}

class OneHourChart extends KollChart {
  OneHourChart({double height, Key key})
      : super(height: height, url: urls.OneHourChartURL, key: key);
}

class CustomChart extends KollChart {
  CustomChart({double height, int startDate, int endDate, Key key})
      : super(
          key: key,
          height: height,
          url: urls.CustomChartURL + '?ki=$startDate&vi=$endDate',
        );
}

class WattChart extends KollChart {
  WattChart({double height, int startDate, int endDate, Key key})
      : super(
          key: key,
          height: height,
          url: urls.wattChartURL + '?ki=$startDate&vi=$endDate',
          wattChart: true,
        );
}

import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hokollektor/Loading.dart';
import 'package:hokollektor/bloc/AppDataBloc.dart';
import 'package:hokollektor/bloc/DataClasses.dart';
import 'package:hokollektor/chart/ChartExplanation.dart';
import 'package:hokollektor/chart/ChartLogic.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/URLs.dart' as urls;

class KollChart extends StatefulWidget {
  final String url;
  final double height;
  final bool animate;
  final bool clickable;

  KollChart({
    @required this.url,
    this.animate = true,
    this.height = 300.0,
    this.clickable = false,
  });

  @override
  KollChartState createState() {
    return new KollChartState();
  }
}

class KollChartState extends State<KollChart>
    with AutomaticKeepAliveClientMixin {
  bool reloading = false;
  bool disposed = false;

  Future<List<charts.Series<ChartDataPoint, DateTime>>> _fetch() async {
    var data;

    try {
      data = await fetchChartData(widget.url);
    } catch (e) {
      print(e.toString());
    }
    reloading = false;
    return data;
  }

  @override
  void dispose() {
    disposed = true;
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
      absorbing: !loaded || !widget.clickable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.height,
            child: _buildChart(context, snapshot),
          ),
          loaded ? ChartExplanation() : Container(),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return charts.TimeSeriesChart(
        snapshot.data,
        animate: _animate,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
      );
    } else if (snapshot.hasError && !reloading) {
      return Center(
        child: InkWell(
          onTap: () => this.setState(() {
                reloading = true;
              }),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error),
              Text(loc.getText(loc.failedToLoadChart)),
            ],
          ),
        ),
      );
    } else
      return Center(
        child: CollectorProgressIndicator(),
      );
  }

  @override
  bool get wantKeepAlive => true;
}

class PreloadedKollChart extends StatefulWidget {
  final AppBloc bloc;
  final double height;
  final bool animate;
  final bool clickable;

  PreloadedKollChart({
    @required this.bloc,
    this.animate = true,
    this.height = 300.0,
    this.clickable = false,
  });

  @override
  PreloadedKollChartState createState() {
    return new PreloadedKollChartState();
  }
}

class PreloadedKollChartState extends State<PreloadedKollChart>
    with AutomaticKeepAliveClientMixin {
  bool reloading = false;
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
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
      absorbing: !loaded || !widget.clickable,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.height,
            child: _buildChart(context, snapshot),
          ),
          loaded ? ChartExplanation() : Container(),
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
    } else if (snapshot.failed && !reloading) {
      return Center(
        child: InkWell(
          onTap: () => this.setState(() {
                reloading = true;
              }),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error),
              Text(loc.getText(loc.failedToLoadChart)),
            ],
          ),
        ),
      );
    } else
      return Center(
        child: CollectorProgressIndicator(),
      );
  }

  @override
  bool get wantKeepAlive => true;
}

class RealTimeChart extends PreloadedKollChart {
  RealTimeChart({
    @required AppBloc bloc,
    double height,
  }) : super(
          height: height,
          bloc: bloc,
        );
}

class OneDayChart extends KollChart {
  OneDayChart({double height})
      : super(
          height: height,
          url: urls.OneDayChartURL,
        );
}

class OneWeekChart extends KollChart {
  OneWeekChart({double height})
      : super(
          height: height,
          url: urls.OneWeekChartURL,
        );
}

class OneHourChart extends KollChart {
  OneHourChart({double height})
      : super(
          height: height,
          url: urls.OneHourChartURL,
        );
}

class CustomChart extends KollChart {
  CustomChart({
    double height,
    int startDate,
    int endDate,
  }) : super(
            height: height,
            url: urls.CustomChartURL + '?ki=$startDate&vi=$endDate');
}

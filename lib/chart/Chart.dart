import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:hokollektor/Loading.dart';
import 'package:hokollektor/chart/ChartExplanation.dart';
import 'package:hokollektor/chart/ChartLogic.dart';
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
              Text("Falied to load!"),
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

class RealtimeKollChart extends StatefulWidget {
  final String url;
  final double height;
  final bool animate;
  final bool clickable;

  RealtimeKollChart({
    @required this.url,
    this.animate = true,
    this.height = 300.0,
    this.clickable = false,
  });

  @override
  RealtimeKollChartState createState() {
    return new RealtimeKollChartState();
  }
}

class RealtimeKollChartState extends State<RealtimeKollChart>
    with AutomaticKeepAliveClientMixin {
  bool disposed = false;
  List oldData = [];
  bool loaded = false;
  bool firstLaunch = true;
  Timer timer;

  bool isAnimate = true;

  bool get animate {
    if (isAnimate) {
      isAnimate = false;
      return true;
    }
    return false;
  }

  Future<List<charts.Series<ChartDataPoint, DateTime>>> _fetch() async {
    final result = await fetchChartData(widget.url);

    if (result != null) loaded = true;

    return result;
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!firstLaunch) {
        if (loaded) {
          this.setState(() {
            this.isAnimate = false;
          });
        }
      } else {
        firstLaunch = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetch(),
      builder: _build,
    );
  }

  Widget _build(BuildContext context, AsyncSnapshot snapshot) {
    bool isLoaded = this.loaded || (snapshot.hasData && !snapshot.hasError);

    bool absorbing = isLoaded;

    return AbsorbPointer(
      absorbing: absorbing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: widget.height,
            child: _buildChart(context, snapshot),
          ),
          isLoaded ? ChartExplanation() : Container(),
        ],
      ),
    );
  }

  Widget _buildChart(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      oldData = snapshot.data;
      return charts.TimeSeriesChart(
        snapshot.data,
        animate: widget.animate && animate,
        dateTimeFactory: charts.LocalDateTimeFactory(),
      );
    } else if (snapshot.hasError) {
      return oldData.isEmpty
          ? InkWell(
              onTap: () => this.setState(() {}),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error),
                    Text("Falied to load!"),
                  ],
                ),
              ),
            )
          : charts.TimeSeriesChart(
              oldData,
              animate: widget.animate && animate,
              dateTimeFactory: charts.LocalDateTimeFactory(),
            );
    } else {
      return oldData.isEmpty
          ? Center(
              child: CollectorProgressIndicator(),
            )
          : charts.TimeSeriesChart(
              oldData,
              animate: widget.animate && animate,
              dateTimeFactory: charts.LocalDateTimeFactory(),
            );
    }
  }

  @override
  void dispose() {
    disposed = true;
    timer.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

class RealTimeChart extends RealtimeKollChart {
  RealTimeChart({double height})
      : super(
          height: height,
          url: urls.RealTimeChartURL,
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

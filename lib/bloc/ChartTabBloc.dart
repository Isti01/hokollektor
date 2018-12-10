import 'package:bloc/bloc.dart';
import 'package:hokollektor/chart/Chart.dart';

final initialChart = charts.weekly;
final initialChartWidget = OneWeekChart();

enum charts {
  daily,
  weekly,
  hourly,
  realTime,
  custom,
}

class ChartTabBloc extends Bloc<ChartEvent, ChartTabState> {
  charts initial = initialChart;
  int startDate;
  int endDate;

  @override
  ChartTabState get initialState {
    return ChartTabState(
      this.initial,
      endDate: endDate,
      startDate: startDate,
    );
  }

  @override
  Stream<ChartTabState> mapEventToState(
      ChartTabState state, ChartEvent event) async* {
    try {
      if (event == null) {
        this.initial = charts.weekly;
        yield ChartTabState(charts.weekly);
      }
    } catch (e) {
      print(e);
    }
    if (event is CustomChartTabEvent) {
      this.initial = charts.custom;
      this.startDate = event.startDate;
      this.endDate = event.endDate;
      yield ChartTabState(
        event.newChart,
        startDate: event.startDate,
        endDate: event.endDate,
      );
    }

    if (event is ChartTabEvent) {
      this.initial = event.newChart;
      yield ChartTabState(event.newChart);
    } else if (event is CustomChartTabEvent) {
      this.initial = event.newChart;
      yield ChartTabState(
        event.newChart,
        startDate: event.startDate,
        endDate: event.endDate,
      );
    }
  }
}

abstract class ChartEvent {}

class ChartTabEvent extends ChartEvent {
  final charts newChart;

  ChartTabEvent(this.newChart);
}

class CustomChartTabEvent extends ChartEvent {
  final int startDate, endDate;
  final charts newChart;

  CustomChartTabEvent(
    this.newChart,
    this.startDate,
    this.endDate,
  );
}

class ChartTabState {
  final charts chart;
  final int startDate, endDate;

  ChartTabState(
    this.chart, {
    this.startDate,
    this.endDate,
  }) : assert(chart != charts.custom || (startDate != null && endDate != null));
}

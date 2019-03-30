import 'package:bloc/bloc.dart';
import 'package:hokollektor/chart/Chart.dart';

final initialChart = Charts.weekly;
final initialChartWidget = OneWeekChart();

enum Charts {
  daily,
  weekly,
  hourly,
  realTime,
  custom,
  watt,
}

class ChartTabBloc extends Bloc<ChartEvent, ChartTabState> {
  Charts initial = initialChart;
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
  Stream<ChartTabState> mapEventToState(ChartEvent event) async* {
    try {
      if (event == null) {
        this.initial = Charts.weekly;
        yield ChartTabState(Charts.weekly);
      }
    } catch (e) {
      print(e);
    }
    if (event is CustomChartTabEvent) {
      this.initial = Charts.custom;
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
  final Charts newChart;

  ChartTabEvent(this.newChart);
}

class CustomChartTabEvent extends ChartEvent {
  final int startDate, endDate;
  final Charts newChart;

  CustomChartTabEvent(
    this.newChart,
    this.startDate,
    this.endDate,
  );
}

class ChartTabState {
  final Charts chart;
  final int startDate, endDate;

  ChartTabState(
    this.chart, {
    this.startDate,
    this.endDate,
  }) : assert(chart != Charts.custom || (startDate != null && endDate != null));
}

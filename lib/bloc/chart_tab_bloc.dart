import 'package:bloc/bloc.dart';
import 'package:hokollektor/chart/chart.dart';

const initialChart = Charts.weekly;
const kChartHeight = 450.0;
final initialChartWidget = OneWeekChart(height: kChartHeight);

enum Charts {
  daily,
  weekly,
  hourly,
  realTime,
  custom,
  watt,
}

class ChartTabBloc extends Bloc<ChartEvent, ChartTabState> {
  ChartTabBloc() : super(ChartTabState(initialChart));

  @override
  Stream<ChartTabState> mapEventToState(ChartEvent event) async* {
    if (event is CustomChartTabEvent) {
      yield ChartTabState(
        event.newChart,
        startDate: event.startDate,
        endDate: event.endDate,
      );
    }

    if (event is ChartTabEvent) {
      yield ChartTabState(event.newChart);
    } else if (event is CustomChartTabEvent) {
      yield ChartTabState(
        event.newChart,
        startDate: event.startDate,
        endDate: event.endDate,
      );
    }
  }
}

abstract class ChartEvent {
  const ChartEvent();
}

class ChartTabEvent extends ChartEvent {
  final Charts newChart;

  const ChartTabEvent(this.newChart);
}

class CustomChartTabEvent extends ChartEvent {
  final int startDate, endDate;
  final Charts newChart;

  const CustomChartTabEvent(
    this.newChart,
    this.startDate,
    this.endDate,
  );
}

class ChartTabState {
  final Charts chart;
  final int? startDate, endDate;

  const ChartTabState(
    this.chart, {
    this.startDate,
    this.endDate,
  }) : assert(chart != Charts.custom || (startDate != null && endDate != null));
}

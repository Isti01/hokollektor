import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///  * <https://material.io/guidelines/components/pickers.html#pickers-date-pickers>
enum DatePickerMode {
  /// Show a date picker UI for choosing a month and day.
  day,

  /// Show a date picker UI for choosing a year.
  year,
}

class _MonthPickerSortKey extends OrdinalSortKey {
  const _MonthPickerSortKey(double order) : super(order);

  static const _MonthPickerSortKey previousMonth = _MonthPickerSortKey(1.0);
  static const _MonthPickerSortKey nextMonth = _MonthPickerSortKey(2.0);
  static const _MonthPickerSortKey calendar = _MonthPickerSortKey(3.0);
}

const Duration _kMonthScrollDuration = Duration(milliseconds: 200);
const double _kDayPickerRowHeight = 42.0;
const int _kMaxDayPickerRowCount = 6; // A 31 day month that starts on Saturday.
// Two extra rows: one for the day-of-week header and one for the month header.
const double _kMaxDayPickerHeight =
    _kDayPickerRowHeight * (_kMaxDayPickerRowCount + 2);

const double _kMonthPickerPortraitWidth = 330.0;

class DayPicker extends StatelessWidget {
  DayPicker({
    Key key,
    @required this.selectedDate2,
    @required this.selectedDate,
    @required this.currentDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    @required this.displayedMonth,
    this.selectableDayPredicate,
  })  : assert(currentDate != null),
        assert(onChanged != null),
        assert(displayedMonth != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(selectedDate == null ||
            selectedDate.isAfter(firstDate) ||
            selectedDate.isAtSameMomentAs(firstDate)),
        assert(selectedDate2 == null ||
            selectedDate2.isAfter(firstDate) ||
            selectedDate2.isAtSameMomentAs(firstDate)),
        super(key: key);

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  final DateTime selectedDate2;

  /// The current date at the time the picker is displayed.
  final DateTime currentDate;

  /// Called when the user picks a day.
  final Function(DateTime time1, DateTime time2) onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// The month whose days are displayed by this picker.
  final DateTime displayedMonth;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate selectableDayPredicate;

  Widget _outOfMonthSelected(themeData) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              style: BorderStyle.solid,
              color: themeData.accentColor,
            ),
            bottom: BorderSide(
              style: BorderStyle.solid,
              color: themeData.accentColor,
            ),
            left: BorderSide(
              style: BorderStyle.solid,
              color: Color.lerp(themeData.accentColor, Colors.white, 0.5),
            ),
            right: BorderSide(
              style: BorderStyle.solid,
              color: Color.lerp(themeData.accentColor, Colors.white, 0.5),
            ),
          ),
          color: Color.lerp(themeData.accentColor, Colors.white, 0.5),
          shape: BoxShape.rectangle),
      margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
    );
  }

  /// Builds widgets showing abbreviated days of week. The first widget in the
  /// returned list corresponds to the first day of week for the current locale.
  ///
  /// Examples:
  ///
  /// ```
  /// ┌ Sunday is the first day of week in the US (en_US)
  /// |
  /// S M T W T F S  <-- the returned list contains these widgets
  /// _ _ _ _ _ 1 2
  /// 3 4 5 6 7 8 9
  ///
  /// ┌ But it's Monday in the UK (en_GB)
  /// |
  /// M T W T F S S  <-- the returned list contains these widgets
  /// _ _ _ _ 1 2 3
  /// 4 5 6 7 8 9 10
  /// ```
  List<Widget> _getDayHeaders(
      TextStyle headerStyle, MaterialLocalizations localizations) {
    final List<Widget> result = <Widget>[];
    for (int i = localizations.firstDayOfWeekIndex; true; i = (i + 1) % 7) {
      final String weekday = localizations.narrowWeekdays[i];
      result.add(ExcludeSemantics(
        child: Center(child: Text(weekday, style: headerStyle)),
      ));
      if (i == (localizations.firstDayOfWeekIndex - 1) % 7) break;
    }
    return result;
  }

  // Do not use this directly - call getDaysInMonth instead.
  static const List<int> _daysInMonth = <int>[
    31,
    -1,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];

  /// Returns the number of days in a month, according to the proleptic
  /// Gregorian calendar.
  ///
  /// This applies the leap year logic introduced by the Gregorian reforms of
  /// 1582. It will not give valid results for dates prior to that time.
  static int getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      final bool isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      if (isLeapYear) return 29;
      return 28;
    }
    return _daysInMonth[month - 1];
  }

  /// Computes the offset from the first day of week that the first day of the
  /// [month] falls on.
  ///
  /// For example, September 1, 2017 falls on a Friday, which in the calendar
  /// localized for United States English appears as:
  ///
  /// ```
  /// S M T W T F S
  /// _ _ _ _ _ 1 2
  /// ```
  ///
  /// The offset for the first day of the months is the number of leading blanks
  /// in the calendar, i.e. 5.
  ///
  /// The same date localized for the Russian calendar has a different offset,
  /// because the first day of week is Monday rather than Sunday:
  ///
  /// ```
  /// M T W T F S S
  /// _ _ _ _ 1 2 3
  /// ```
  ///
  /// So the offset is 4, rather than 5.
  ///
  /// This code consolidates the following:
  ///
  /// - [DateTime.weekday] provides a 1-based index into days of week, with 1
  ///   falling on Monday.
  /// - [MaterialLocalizations.firstDayOfWeekIndex] provides a 0-based index
  ///   into the [MaterialLocalizations.narrowWeekdays] list.
  /// - [MaterialLocalizations.narrowWeekdays] list provides localized names of
  ///   days of week, always starting with Sunday and ending with Saturday.
  int _computeFirstDayOffset(
      int year, int month, MaterialLocalizations localizations) {
    // 0-based day of week, with 0 representing Monday.
    final int weekdayFromMonday = DateTime(year, month).weekday - 1;
    // 0-based day of week, with 0 representing Sunday.
    final int firstDayOfWeekFromSunday = localizations.firstDayOfWeekIndex;
    // firstDayOfWeekFromSunday recomputed to be Monday-based
    final int firstDayOfWeekFromMonday = (firstDayOfWeekFromSunday - 1) % 7;
    // Number of days between the first day of week appearing on the calendar,
    // and the day corresponding to the 1-st of the month.
    return (weekdayFromMonday - firstDayOfWeekFromMonday) % 7;
  }

  bool _isBetween(DateTime date1, DateTime date2, DateTime selDate) {
    if (date1 == null || date2 == null) return false;
    return selDate.isAfter(date1) && selDate.isBefore(date2);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final int year = displayedMonth.year;
    final int month = displayedMonth.month;
    final int daysInMonth = getDaysInMonth(year, month);
    final int firstDayOffset =
        _computeFirstDayOffset(year, month, localizations);
    final List<Widget> labels = <Widget>[];
    DateTime date1;
    DateTime date2;

    if (selectedDate2 != null &&
        selectedDate != null &&
        selectedDate2.isAfter(selectedDate)) {
      date1 = selectedDate;
      date2 = selectedDate2;
    } else {
      date1 = selectedDate2;
      date2 = selectedDate;
    }
    labels.addAll(_getDayHeaders(themeData.textTheme.caption, localizations));
    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final int day = i - firstDayOffset + 1;
      if (day > daysInMonth) {
        break;
      }
      if (day < 1) {
        // print([day < 0, day, month, firstDayOffset]);
        if (_isBetween(
            date1,
            date2,
            DateTime(year, month, 1).subtract(Duration(
              hours: 23,
              minutes: 59,
              seconds: 59,
            ))))
          labels.add(_outOfMonthSelected(themeData));
        else
          labels.add(Container());
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool disabled = dayToBuild.isAfter(lastDate) ||
            dayToBuild.isBefore(firstDate) ||
            (selectableDayPredicate != null &&
                !selectableDayPredicate(dayToBuild));

        BoxDecoration decoration;
        TextStyle itemStyle = themeData.textTheme.body1;

        bool nullDate = false;

        bool isSelectedDay = false;
        if (date1 != null) {
          isSelectedDay =
              date1.year == year && date1.month == month && date1.day == day;
        } else
          nullDate = true;

        bool isSelectedDay2 = false;

        if (date2 != null) {
          isSelectedDay2 =
              date2.year == year && date2.month == month && date2.day == day;
        } else
          nullDate = true;

        bool betweenSelectedDates = !nullDate;
        if (!nullDate) {
          int date1Val = date1.millisecondsSinceEpoch;
          int date2val = date2.millisecondsSinceEpoch;
          int selectedDateVal =
              DateTime(year, month, day).millisecondsSinceEpoch;

          if (selectedDateVal > date2val || selectedDateVal < date1Val)
            betweenSelectedDates = false;
        }
        if (isSelectedDay || isSelectedDay2 || betweenSelectedDates) {
          // The selected day gets a circle background highlight, and a contrasting text color.
          itemStyle = themeData.accentTextTheme.body2;
          if (nullDate) {
            decoration = BoxDecoration(
              color: themeData.accentColor,
              shape: BoxShape.circle,
            );
          } else if (isSelectedDay) {
            decoration = BoxDecoration(
                border: Border.all(
                  style: BorderStyle.solid,
                  color: themeData.accentColor,
                ),
                color: themeData.accentColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    bottomLeft: Radius.circular(100)));
          } else if (isSelectedDay2) {
            decoration = BoxDecoration(
                border: Border.all(
                  style: BorderStyle.solid,
                  color: themeData.accentColor,
                ),
                color: themeData.accentColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(100),
                    bottomRight: Radius.circular(100)));
          } else {
            decoration = BoxDecoration(
                border: Border.all(
                  style: BorderStyle.solid,
                  color: themeData.accentColor,
                ),
                color: themeData.accentColor,
                shape: BoxShape.rectangle);
          }
        } else if (disabled) {
          itemStyle = themeData.textTheme.body1
              .copyWith(color: themeData.disabledColor);
        }

        Widget dayWidget = Container(
          margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 0.0),
          decoration: decoration,
          child: Center(
            child: Semantics(
              // We want the day of month to be spoken first irrespective of the
              // locale-specific preferences or TextDirection. This is because
              // an accessibility user is more likely to be interested in the
              // day of month before the rest of the date, as they are looking
              // for the day of month. To do that we prepend day of month to the
              // formatted full date.
              label:
                  '${localizations.formatDecimal(day)}, ${localizations.formatFullDate(dayToBuild)}',
              selected: isSelectedDay,
              child: ExcludeSemantics(
                child: Text(localizations.formatDecimal(day), style: itemStyle),
              ),
            ),
          ),
        );

        if (!disabled) {
          dayWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (selectedDate == null || selectedDate2 == null) {
                DateTime otherTime = selectedDate ?? selectedDate2;

                if (dayToBuild.year == otherTime.year &&
                    dayToBuild.month == otherTime.month &&
                    dayToBuild.day == otherTime.day) return;

                if (otherTime.isAfter(dayToBuild))
                  onChanged(dayToBuild, otherTime);
                else
                  onChanged(dayToBuild, otherTime);
              } else if (dayToBuild.year == selectedDate.year &&
                  dayToBuild.month == selectedDate.month &&
                  dayToBuild.day == selectedDate.day) {
                if (selectedDate2 != null) onChanged(selectedDate, null);
              } else if (dayToBuild.year == selectedDate2.year &&
                  dayToBuild.month == selectedDate2.month &&
                  dayToBuild.day == selectedDate2.day) {
                if (selectedDate != null) onChanged(null, selectedDate2);
              } else {
                onChanged(dayToBuild, null);

                /*final dif1 = selectedDate.difference(dayToBuild).inDays.abs();
                final dif2 = selectedDate2.difference(dayToBuild).inDays.abs();

                print(
                    'Date1: ${selectedDate.toString()} Date2: ${selectedDate2.toString()}');
                print('Dif1 $dif1, Dif2: $dif2');

                if (dif1 < dif2) {
                  onChanged(dayToBuild, selectedDate2);
                } else {
                  onChanged(selectedDate, dayToBuild);
                }*/
              }
            },
            child: dayWidget,
          );
        }

        labels.add(dayWidget);
      }
    }

    if (_isBetween(
        date1,
        date2,
        DateTime(year, month, daysInMonth).add(Duration(
          hours: 23,
          minutes: 59,
          seconds: 59,
        )))) {
      int iteration = labels.length % 7 == 0 ? 0 : 7 - labels.length % 7;

      for (int i = 0; i < iteration; i++) {
        labels.add(_outOfMonthSelected(themeData));
      }

      //print('adding placeholders with iteartion $iteration');
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: _kDayPickerRowHeight,
          child: Center(
            child: ExcludeSemantics(
              child: Text(
                localizations.formatMonthYear(displayedMonth),
                style: themeData.textTheme.subhead,
              ),
            ),
          ),
        ),
        Flexible(
          child: GridView.custom(
            gridDelegate: _kDayPickerGridDelegate,
            childrenDelegate:
                SliverChildListDelegate(labels, addRepaintBoundaries: false),
          ),
        ),
      ],
    );
  }
}

class DayPickerGridDelegate extends SliverGridDelegate {
  const DayPickerGridDelegate();

  @override
  bool shouldRelayout(DayPickerGridDelegate oldDelegate) => false;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    const int columnCount = DateTime.daysPerWeek;
    final double tileWidth = constraints.crossAxisExtent / columnCount;
    final double tileHeight = math.min(_kDayPickerRowHeight,
        constraints.viewportMainAxisExtent / (_kMaxDayPickerRowCount + 1));
    return SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: tileHeight,
      crossAxisStride: tileWidth,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }
}

const DayPickerGridDelegate _kDayPickerGridDelegate = DayPickerGridDelegate();

class MonthPicker extends StatefulWidget {
  /// Creates a month picker.
  ///
  /// Rarely used directly. Instead, typically used as part of the dialog shown
  /// by [showDatePicker].
  MonthPicker({
    Key key,
    @required this.selectedDate,
    @required this.onChanged,
    @required this.firstDate,
    @required this.lastDate,
    @required this.maxInterval,
    this.selectableDayPredicate,
    this.selectedDate2,
  })  : assert(onChanged != null),
        assert(!firstDate.isAfter(lastDate)),
        assert(maxInterval != null),
        assert(selectedDate == null ||
            selectedDate.isAfter(firstDate) ||
            selectedDate.isAtSameMomentAs(firstDate)),
        assert(selectedDate2 == null ||
            selectedDate2.isAfter(firstDate) ||
            selectedDate2.isAtSameMomentAs(firstDate)),
        super(key: key);

  final DateTime selectedDate2;

  /// The currently selected date.
  ///
  /// This date is highlighted in the picker.
  final DateTime selectedDate;

  /// Called when the user picks a month.
  final Function(DateTime time1, DateTime time2) onChanged;

  /// The earliest date the user is permitted to pick.
  final DateTime firstDate;

  final Duration maxInterval;

  /// The latest date the user is permitted to pick.
  final DateTime lastDate;

  /// Optional user supplied predicate function to customize selectable days.
  final SelectableDayPredicate selectableDayPredicate;

  @override
  _MonthPickerState createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker>
    with SingleTickerProviderStateMixin {
  static final Animatable<double> _chevronOpacityTween =
      Tween<double>(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    // Initially display the pre-selected date.
    final int monthPage = _monthDelta(
        widget.firstDate, widget.selectedDate ?? widget.selectedDate2);
    _dayPickerController = PageController(initialPage: monthPage);
    _handleMonthPageChanged(monthPage);
    _updateCurrentDate();

    // Setup the fade animation for chevrons
    _chevronOpacityController = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    _chevronOpacityAnimation =
        _chevronOpacityController.drive(_chevronOpacityTween);
  }

  @override
  void didUpdateWidget(MonthPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      final int monthPage = _monthDelta(
          widget.firstDate, widget.selectedDate ?? widget.selectedDate2);
      _dayPickerController = PageController(initialPage: monthPage);
      _handleMonthPageChanged(monthPage);
    }
  }

  MaterialLocalizations localizations;
  TextDirection textDirection;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    textDirection = Directionality.of(context);
  }

  DateTime _todayDate;
  DateTime _currentDisplayedMonthDate;
  Timer _timer;
  PageController _dayPickerController;
  AnimationController _chevronOpacityController;
  Animation<double> _chevronOpacityAnimation;

  void _updateCurrentDate() {
    _todayDate = DateTime.now();
    final DateTime tomorrow =
        DateTime(_todayDate.year, _todayDate.month, _todayDate.day + 1);
    Duration timeUntilTomorrow = tomorrow.difference(_todayDate);
    timeUntilTomorrow +=
        const Duration(seconds: 1); // so we don't miss it by rounding
    _timer?.cancel();
    _timer = Timer(timeUntilTomorrow, () {
      setState(() {
        _updateCurrentDate();
      });
    });
  }

  static int _monthDelta(DateTime startDate, DateTime endDate) {
    return (endDate.year - startDate.year) * 12 +
        endDate.month -
        startDate.month;
  }

  /// Add months to a month truncated date.
  DateTime _addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    return DateTime(
        monthDate.year + monthsToAdd ~/ 12, monthDate.month + monthsToAdd % 12);
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime month = _addMonthsToMonthDate(widget.firstDate, index);

    DateTime firstDate = widget.firstDate;
    DateTime lastDate;

    if (widget.selectedDate == null || widget.selectedDate2 == null) {
      final selected = widget.selectedDate ?? widget.selectedDate2;

      firstDate = selected.subtract(widget.maxInterval);
      lastDate = selected.add(widget.maxInterval);
    }
    if (lastDate == null || widget.lastDate.isBefore(lastDate))
      lastDate = widget.lastDate;

    return DayPicker(
      key: ValueKey<DateTime>(month),
      selectedDate: widget.selectedDate,
      currentDate: _todayDate,
      onChanged: widget.onChanged,
      firstDate: firstDate,
      lastDate: lastDate,
      displayedMonth: month,
      selectedDate2: widget.selectedDate2,
    );
  }

  void _handleNextMonth() {
    if (!_isDisplayingLastMonth) {
      SemanticsService.announce(
          localizations.formatMonthYear(_nextMonthDate), textDirection);
      _dayPickerController.nextPage(
          duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  void _handlePreviousMonth() {
    if (!_isDisplayingFirstMonth) {
      SemanticsService.announce(
          localizations.formatMonthYear(_previousMonthDate), textDirection);
      _dayPickerController.previousPage(
          duration: _kMonthScrollDuration, curve: Curves.ease);
    }
  }

  /// True if the earliest allowable month is displayed.
  bool get _isDisplayingFirstMonth {
    return !_currentDisplayedMonthDate
        .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month));
  }

  /// True if the latest allowable month is displayed.
  bool get _isDisplayingLastMonth {
    return !_currentDisplayedMonthDate
        .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));
  }

  DateTime _previousMonthDate;
  DateTime _nextMonthDate;

  void _handleMonthPageChanged(int monthPage) {
    setState(() {
      _previousMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage - 1);
      _currentDisplayedMonthDate =
          _addMonthsToMonthDate(widget.firstDate, monthPage);
      _nextMonthDate = _addMonthsToMonthDate(widget.firstDate, monthPage + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kMonthPickerPortraitWidth,
      height: _kMaxDayPickerHeight,
      child: Stack(
        children: <Widget>[
          Semantics(
            sortKey: _MonthPickerSortKey.calendar,
            child: NotificationListener<ScrollStartNotification>(
              onNotification: (_) {
                _chevronOpacityController.forward();
                return false;
              },
              child: NotificationListener<ScrollEndNotification>(
                onNotification: (_) {
                  _chevronOpacityController.reverse();
                  return false;
                },
                child: PageView.builder(
                  key: ValueKey<DateTime>(widget.selectedDate),
                  controller: _dayPickerController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _monthDelta(widget.firstDate, widget.lastDate) + 1,
                  itemBuilder: _buildItems,
                  onPageChanged: _handleMonthPageChanged,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            start: 8.0,
            child: Semantics(
              sortKey: _MonthPickerSortKey.previousMonth,
              child: FadeTransition(
                opacity: _chevronOpacityAnimation,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: _isDisplayingFirstMonth
                      ? null
                      : '${localizations.previousMonthTooltip} ${localizations.formatMonthYear(_previousMonthDate)}',
                  onPressed:
                      _isDisplayingFirstMonth ? null : _handlePreviousMonth,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0.0,
            end: 8.0,
            child: Semantics(
              sortKey: _MonthPickerSortKey.nextMonth,
              child: FadeTransition(
                opacity: _chevronOpacityAnimation,
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: _isDisplayingLastMonth
                      ? null
                      : '${localizations.nextMonthTooltip} ${localizations.formatMonthYear(_nextMonthDate)}',
                  onPressed: _isDisplayingLastMonth ? null : _handleNextMonth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dayPickerController?.dispose();
    super.dispose();
  }
}

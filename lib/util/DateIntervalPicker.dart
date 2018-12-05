import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const double _kDayPickerRowHeight = .0;

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
    labels.addAll(_getDayHeaders(themeData.textTheme.caption, localizations));
    for (int i = 0; true; i += 1) {
      // 1-based day of month, e.g. 1-31 for January, and 1-29 for February on
      // a leap year.
      final int day = i - firstDayOffset + 1;
      if (day > daysInMonth) break;
      if (day < 1) {
        labels.add(Container());
      } else {
        final DateTime dayToBuild = DateTime(year, month, day);
        final bool disabled = dayToBuild.isAfter(lastDate) ||
            dayToBuild.isBefore(firstDate) ||
            (selectableDayPredicate != null &&
                !selectableDayPredicate(dayToBuild));

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
          if (date1.year > year || date2.year < year) {
            betweenSelectedDates = false;
          }
          if (date1.month > month || date2.month < month) {
            betweenSelectedDates = false;
          }
          if (date1.day >= day || date2.day <= day) {
            betweenSelectedDates = false;
          }
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
const int _kMaxDayPickerRowCount = 6;

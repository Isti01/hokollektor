import "dart:developer" as developer;

import 'package:flutter/material.dart';
import 'package:hokollektor/home/home.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/util/date_interval_picker.dart' as picker;
import 'package:hokollektor/util/simple_scroll_behavior.dart';

const int kLastDay = 15;
final DateTime kFirstDate = DateTime(2018, 1, 1);
const Duration kMaxInterval = Duration(days: 14);

class DatePickerDialog extends StatefulWidget {
  const DatePickerDialog({Key key}) : super(key: key);

  @override
  DatePickerDialogState createState() => DatePickerDialogState();
}

class DatePickerDialogState extends State<DatePickerDialog> {
  DateTime firstDate;
  DateTime lastDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    firstDate = DateTime(now.year, now.month, now.day);
    lastDate = DateTime(now.year, now.month, now.day, 23, 59)
        .subtract(const Duration(days: kLastDay - 1));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final theme = Theme.of(context).textTheme;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: kAppBorderRadius),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 300,
                child: _buildDatePickerCard(
                  title: loc.getText(loc.pickInterval),
                  theme: theme,
                  selectedDate2: lastDate,
                  currentDate: firstDate,
                  now: now,
                  onDateChanged: _handleDateChange,
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  OutlineButton(
                      child: Text(loc.getText(loc.cancel)),
                      borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                      shape: const RoundedRectangleBorder(
                          borderRadius: kAppBorderRadius),
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () => Navigator.pop(context)),
                  RaisedButton(
                    child: Text(loc.getText(loc.save)),
                    shape: const RoundedRectangleBorder(
                        borderRadius: kAppBorderRadius),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      List<DateTime> result;
                      try {
                        try {
                          result = [
                            firstDate.isAfter(lastDate) ? lastDate : firstDate,
                            firstDate.isAfter(lastDate) ? firstDate : lastDate,
                          ];
                        } catch (e) {
                          result = [
                            firstDate ?? lastDate,
                            firstDate ?? lastDate,
                          ];
                        }
                        if (result[0] != null && result[1] != null) {
                          Navigator.pop(context, result);
                        }
                      } catch (e) {
                        developer.log(e);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerCard({
    String title,
    DateTime currentDate,
    onDateChanged,
    now,
    theme,
    DateTime selectedDate2,
  }) {
    return ScrollConfiguration(
      behavior: SimpleScrollBehavior(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: theme.title,
            textAlign: TextAlign.center,
          ),
          Flexible(
            fit: FlexFit.tight,
            child: picker.MonthPicker(
              selectedDate2: selectedDate2,
              selectedDate: currentDate,
              onChanged: onDateChanged,
              firstDate: kFirstDate,
              lastDate: now,
              maxInterval: kMaxInterval,
            ),
          ),
        ],
      ),
    );
  }

  _handleDateChange(DateTime date, DateTime date2) {
    setState(() {
      firstDate = date;
      lastDate = date2;
    });
  }
}

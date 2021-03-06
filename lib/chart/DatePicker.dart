import 'package:flutter/material.dart';
import 'package:hokollektor/Localization.dart' as loc;
import 'package:hokollektor/home/Home.dart';
import 'package:hokollektor/util/DateIntervalPicker.dart' as picker;
import 'package:hokollektor/util/SimpleScrollBehavior.dart';

const int lastDay = 15;
final DateTime FirstDate = DateTime(2018, 1, 1);
const Duration maxInterval = Duration(days: 14);

class DatePickerDialog extends StatefulWidget {
  @override
  DatePickerDialogState createState() {
    return new DatePickerDialogState();
  }
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
        .subtract(Duration(days: lastDay - 1));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final theme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: appBorderRadius),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
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
                          borderRadius: appBorderRadius),
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () => Navigator.pop(context)),
                  RaisedButton(
                    child: Text(loc.getText(loc.save)),
                    shape: const RoundedRectangleBorder(
                        borderRadius: appBorderRadius),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      var result;
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
                        if (result[0] != null && result[1] != null)
                          Navigator.pop(context, result);
                      } catch (e) {
                        print(e);
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
              firstDate: FirstDate,
              lastDate: now,
              maxInterval: maxInterval,
            ),
          ),
        ],
      ),
    );
  }

  _handleDateChange(DateTime date, DateTime date2) {
    this.setState(() {
      this.firstDate = date;
      this.lastDate = date2;
    });
  }
}

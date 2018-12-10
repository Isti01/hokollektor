import 'package:flutter/material.dart';
import 'package:hokollektor/localization.dart' as loc;
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
  DateTime firstDate = DateTime.now();
  DateTime lastDate = DateTime.now().subtract(Duration(days: lastDay - 1));

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final theme = Theme.of(context).textTheme;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 300.0,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    textColor: Theme.of(context).primaryColor,
                    onPressed: () => Navigator.pop(context)),
                RaisedButton(
                  child: Text(loc.getText(loc.save)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
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

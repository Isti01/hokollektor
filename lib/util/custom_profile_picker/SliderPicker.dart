import 'package:flutter/material.dart';
import 'package:hokollektor/localization.dart' as loc;

class MinifiedSliderPicker extends StatelessWidget {
  final List<int> values;
  final Function(List<int> value) onChanged;
  final maxLength = (' 100%  ' + loc.getText(loc.onDeg) + ' 100°C').length;

  MinifiedSliderPicker({
    Key key,
    this.values,
    this.onChanged,
  }) : super(key: key);

  void _onChanged(double value, int index) {
    var copy = values;

    copy[index] = (value * 100).toInt();

    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _mSlider(
          maxLength: this.maxLength,
          label: '0',
          value: values[0] / 100,
          onChanged: (value) => _onChanged(value, 0),
        ),
        _mSlider(
          maxLength: this.maxLength,
          label: '25',
          value: values[1] / 100,
          onChanged: (value) => _onChanged(value, 1),
        ),
        _mSlider(
          maxLength: this.maxLength,
          label: '50',
          value: values[2] / 100,
          onChanged: (value) => _onChanged(value, 2),
        ),
        _mSlider(
          maxLength: this.maxLength,
          label: '75',
          value: values[3] / 100,
          onChanged: (value) => _onChanged(value, 3),
        ),
        _mSlider(
          maxLength: this.maxLength,
          label: '100',
          value: values[4] / 100,
          onChanged: (value) => _onChanged(value, 4),
        ),
      ],
    );
  }
}

class ExpandedSliderPicker extends StatelessWidget {
  final List<int> values;
  final Function(List<int> value) onChanged;
  final maxLength = (' 100% ' + loc.getText(loc.onDeg) + ' 100°C').length;

  ExpandedSliderPicker({Key key, this.values, this.onChanged})
      : super(key: key);

  void _onChanged(double value, int index) {
    var copy = values;

    copy[index] = (value * 100).toInt();

    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _mSlider(
            maxLength: this.maxLength,
            label: '0',
            value: values[0] / 100,
            onChanged: (value) => _onChanged(value, 0),
          ),
          _mSlider(
            maxLength: this.maxLength,
            label: '10',
            value: values[1] / 100,
            onChanged: (value) => _onChanged(value, 1),
          ),
          _mSlider(
            maxLength: this.maxLength,
            label: '20',
            value: values[2] / 100,
            onChanged: (value) => _onChanged(value, 2),
          ),
          _mSlider(
            maxLength: this.maxLength,
            label: '30',
            value: values[3] / 100,
            onChanged: (value) => _onChanged(value, 3),
          ),
          _mSlider(
            maxLength: this.maxLength,
            label: '40',
            value: values[4] / 100,
            onChanged: (value) => _onChanged(value, 4),
          ),
          _mSlider(
            maxLength: this.maxLength,
            label: '50',
            value: values[5] / 100,
            onChanged: (value) => _onChanged(value, 5),
          ),
          _mSlider(
            maxLength: this.maxLength,
            label: '60',
            value: values[6] / 100,
            onChanged: (value) => _onChanged(value, 6),
          ),
          _mSlider(
            maxLength: this.maxLength,
            label: '70',
            value: values[7] / 100,
            onChanged: (value) => _onChanged(value, 7),
          ),
          _mSlider(
            maxLength: this.maxLength,
            label: '85',
            value: values[8] / 100,
            onChanged: (value) => _onChanged(value, 8),
          ),
          _mSlider(
            maxLength: this.maxLength,
            label: '100',
            value: values[9] / 100,
            onChanged: (value) => _onChanged(value, 9),
          ),
        ],
      ),
    );
  }
}

class _mSlider extends StatefulWidget {
  final value;
  final Function(double value) onChanged;
  final String label;
  final maxLength;

  const _mSlider({
    Key key,
    this.value,
    this.onChanged,
    this.label,
    this.maxLength,
  }) : super(key: key);

  @override
  _mSliderState createState() => _mSliderState();
}

class _mSliderState extends State<_mSlider> {
  double value;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    final text = ' ${_mapValue().toString()}% ' +
        loc.getText(loc.onDeg) +
        ' ${widget.label}°C';

    final textToShow = String.fromCharCodes(
            List.generate(widget.maxLength - text.length, (index) {
          return 32;
        })) +
        text;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(textToShow),
        SizedBox(width: 4),
        SizedBox(
          width: size / 2.5,
          child: Slider(
            value: this.value,
            onChanged: (value) => this.setState(() => this.value = value),
            onChangeEnd: widget.onChanged,
          ),
        ),
      ],
    );
  }

  _mapValue() {
    return (this.value * 100).toInt();
  }
}

import 'package:flutter/material.dart';

class MinifiedSliderPicker extends StatelessWidget {
  final List<int> values;
  final Function(List<int> value) onChanged;

  const MinifiedSliderPicker({
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
          label: '0',
          value: values[0] / 100,
          onChanged: (value) => _onChanged(value, 0),
        ),
        _mSlider(
          label: '25',
          value: values[1] / 100,
          onChanged: (value) => _onChanged(value, 1),
        ),
        _mSlider(
          label: '50',
          value: values[2] / 100,
          onChanged: (value) => _onChanged(value, 2),
        ),
        _mSlider(
          label: '75',
          value: values[3] / 100,
          onChanged: (value) => _onChanged(value, 3),
        ),
        _mSlider(
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

  const ExpandedSliderPicker({Key key, this.values, this.onChanged})
      : super(key: key);

  void _onChanged(double value, int index) {
    var copy = values;

    copy[index] = (value * 100).toInt();

    onChanged(copy);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _mSlider(
            label: '0',
            value: values[0] / 100,
            onChanged: (value) => _onChanged(value, 0),
          ),
          _mSlider(
            label: '10',
            value: values[1] / 100,
            onChanged: (value) => _onChanged(value, 1),
          ),
          _mSlider(
            label: '20',
            value: values[2] / 100,
            onChanged: (value) => _onChanged(value, 2),
          ),
          _mSlider(
            label: '30',
            value: values[3] / 100,
            onChanged: (value) => _onChanged(value, 3),
          ),
          _mSlider(
            label: '40',
            value: values[4] / 100,
            onChanged: (value) => _onChanged(value, 4),
          ),
          _mSlider(
            label: '50',
            value: values[5] / 100,
            onChanged: (value) => _onChanged(value, 5),
          ),
          _mSlider(
            label: '60',
            value: values[6] / 100,
            onChanged: (value) => _onChanged(value, 6),
          ),
          _mSlider(
            label: '70',
            value: values[7] / 100,
            onChanged: (value) => _onChanged(value, 7),
          ),
          _mSlider(
            label: '85',
            value: values[8] / 100,
            onChanged: (value) => _onChanged(value, 8),
          ),
          _mSlider(
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

  const _mSlider({Key key, this.value, this.onChanged, this.label})
      : super(key: key);

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
    return SizedBox(
      width: size / 1.4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(' ${_mapValue().toString()}% on ${widget.label}°C'),
          SizedBox(width: 4.0),
          Slider(
            value: this.value,
            onChanged: (value) => this.setState(() => this.value = value),
            onChangeEnd: widget.onChanged,
          ),
        ],
      ),
    );
  }

  _mapValue() {
    return (this.value * 100).toInt();
  }
}

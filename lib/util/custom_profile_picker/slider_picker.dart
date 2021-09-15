import 'package:flutter/material.dart';
import 'package:hokollektor/localization.dart' as loc;

class SliderPicker extends StatelessWidget {
  final List<int> values;
  final Function(List<int> value) onChanged;
  final int maxLength = (' 100%  ' + loc.getText(loc.onDeg) + ' 100°C').length;
  final int numItems;
  final int diffBetweenElements;

  SliderPicker({
    Key key,
    this.values,
    this.onChanged,
    this.numItems,
    this.diffBetweenElements,
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
      children: List.generate(
        numItems,
        (index) => _TempSlider(
          maxLength: maxLength,
          label: (index * diffBetweenElements).toString(),
          value: values[index] / 100,
          onChanged: (value) => _onChanged(value, index),
        ),
      ),
    );
  }
}

class _TempSlider extends StatefulWidget {
  final double value;
  final Function(double value) onChanged;
  final String label;
  final int maxLength;

  const _TempSlider({
    Key key,
    this.value,
    this.onChanged,
    this.label,
    this.maxLength,
  }) : super(key: key);

  @override
  _TempSliderState createState() => _TempSliderState();
}

class _TempSliderState extends State<_TempSlider> {
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
        const SizedBox(width: 4),
        SizedBox(
          width: size / 2.5,
          child: Slider(
            value: value,
            onChanged: (value) => setState(() => this.value = value),
            onChangeEnd: widget.onChanged,
          ),
        ),
      ],
    );
  }

  _mapValue() {
    return (value * 100).toInt();
  }
}

import 'package:flutter/material.dart';
import 'package:hokollektor/Localization.dart' as loc;

class ChartExplanation extends StatelessWidget {
  final collectorText = loc.getText(loc.tempKoll);
  final outsideText = loc.getText(loc.tempOutside);
  final insideText = loc.getText(loc.tempInside);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLine(const Color(0xFFF44336), collectorText),
          _buildLine(const Color(0xff2196f3), outsideText),
          _buildLine(const Color(0xffffeb3b), insideText),
        ],
      ),
    );
  }

  Widget _buildLine(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 15,
            width: 15,
            color: color,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(text),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ProgressMeter extends StatelessWidget {
  final double usage;
  final double total;

  final _background = Colors.blueGrey[100];
  final _colors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.red,
  ];
  final _thresholds = [
    0.5,
    0.3,
    0.1,
    double.negativeInfinity,
  ];
  double _ratio;

  ProgressMeter({Key key, @required this.usage, @required this.total}) : super(key: key) {
    if (usage < 0 || total <= 0 || usage > total || !usage.isFinite || !total.isFinite) {
      _ratio = 0;
      debugPrint("Invalid params sent to progress meter usage($usage), total($total).");
    } else {
     _ratio = 1 - usage / total;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 20,
          width: double.infinity,
          color: _background,
          child: FractionallySizedBox(
          widthFactor: _ratio,
          heightFactor: 1,
          alignment: Alignment.centerLeft,
          child: Container(
            color: _getColor(),
          ),
        )
        ),
      ),
    );
  }

  Color _getColor() {
    for (var i = 0; i < _thresholds.length; i++) {
      if (_ratio > _thresholds[i]) {
        return _colors[i];
      }
    }
    return Colors.black;
  }
}
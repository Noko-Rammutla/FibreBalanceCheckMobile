import 'package:fibre_balance_check/common/usage.dart';
import 'package:flutter/material.dart';

class UsageView extends StatelessWidget {
  final Usage usage;
  final AnimationController animationController;

  UsageView({this.usage, this.animationController});

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 1.0,
      child: Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Colors.black,
              ),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(
              children: <Widget>[
                Text(
                  usage.packageName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(usage.usage,
                        style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(usage.lastUpdate)
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

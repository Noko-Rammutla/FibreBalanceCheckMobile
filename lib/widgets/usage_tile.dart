import 'package:fibre_balance_check/common/usage.dart';
import 'package:flutter/material.dart';

class UsageTile extends StatelessWidget {
  final Usage usage;
  final Function(String option) onContextMenu;

  UsageTile({Key key, this.usage, this.onContextMenu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
          PopupMenuItem(
            value: 'rename',
            child: Text('Rename'),
          )
        ],
        onSelected: onContextMenu,
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
                  child: Text(
                      'You have ${(usage.total - usage.usage).toStringAsFixed(2)} GB remaining.',
                      style: TextStyle(color: Colors.blueGrey)),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(usage.lastUpdate)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

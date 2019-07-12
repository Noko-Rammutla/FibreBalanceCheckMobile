import 'package:fibre_balance_check/common/usage.dart';
import 'package:fibre_balance_check/widgets/progress_meter.dart';
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  usage.packageName,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        TextSpan(text: '${(usage.total - usage.usage).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blueGrey[600])),
                        TextSpan(text: '/',
                          style: TextStyle(color: Colors.grey, fontSize: 20)),
                        TextSpan(text: '${usage.total.toStringAsFixed(2)}'),
                        TextSpan(text: ' GB')
                      ]
                    ),
                  )
                ),
              ),
              ProgressMeter(
                usage: usage.usage,
                total: usage.total,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(usage.lastUpdate, style: TextStyle(color: Colors.grey))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

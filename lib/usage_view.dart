import 'package:fibre_balance_check/common/usage.dart';
import 'package:flutter/material.dart';

class UsageView extends StatefulWidget {
  final Usage usage;
  final AnimationController animationController;
  final Function(Usage, String) onRename;
  final Function(Usage) onDelete;

  UsageView(
      {this.usage, this.animationController, this.onRename, this.onDelete});

  @override
  _UsageViewState createState() => _UsageViewState();
}

class _UsageViewState extends State<UsageView> {
  final TextEditingController _textEditingController = TextEditingController();

  void _onSelected(String value) {
    if (value == 'delete') {
      widget.onDelete(widget.usage);
    } else if (value == 'rename') {
      showDialog(
        context: context,
        builder: _showDialog,
      );
     
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
          parent: widget.animationController, curve: Curves.easeOut),
      axisAlignment: 1.0,
      child: Padding(
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
            onSelected: _onSelected,
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
                    widget.usage.packageName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(widget.usage.usage,
                          style: TextStyle(color: Colors.blueGrey)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(widget.usage.lastUpdate)),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget _showDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Enter new name'),
      content: TextField(
        controller: _textEditingController,
        decoration: InputDecoration(hintText: "Package Name"),
      ),
      actions: <Widget>[
        FlatButton(
          child: new Text('CANCEL'),
          onPressed: () {
            _textEditingController.clear();
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: new Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onRename(widget.usage, _textEditingController.text);
            _textEditingController.clear();
          },
        )
      ],
    );
  }
}

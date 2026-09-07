import 'package:flutter/material.dart';

class CustomMasonry extends StatelessWidget {
  final List<dynamic> listOfItem;
  final int numberOfColumn;
  final Widget Function(dynamic) itemBuilder;

  const CustomMasonry({
    Key? key,
    required this.listOfItem,
    required this.numberOfColumn,
    required this.itemBuilder,
  }) : super(key: key);

  List<dynamic> _items(int start) {
    List<dynamic> items = [];
    for (var i = start; i < listOfItem.length; i = i + numberOfColumn) {
      dynamic item = listOfItem.elementAt(i);
      items.add(item);
    }
    return items;
  }

  List<Widget> _columns() {
    List<Widget> column = [];
    for (var i = 0; i < numberOfColumn; i++) {
      column.add(_column(_items(i)));
    }
    return column;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _columns(),
    );
  }

  Widget _column(List<dynamic> items) {
    return Flexible(
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.all(2),
            child: itemBuilder(item),
          );
        }).toList(),
      ),
    );
  }
}

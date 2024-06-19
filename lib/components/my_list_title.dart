import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTitle extends StatelessWidget {
  final String title;
  final String trailing;
  final String date;
  void Function(BuildContext)? onEditPressed;
  void Function(BuildContext)? onDeletePressed;

  MyListTitle({
    super.key,
    required this.title,
    required this.trailing,
    required this.date,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            // update
            SlidableAction(
              onPressed: onEditPressed,
              icon: Icons.edit,
              backgroundColor: Colors.green,
            ),
            SlidableAction(
              onPressed: onDeletePressed,
              icon: Icons.delete,
              backgroundColor: Colors.red,
            )
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
          child: ListTile(
            title: Text(title, style: const TextStyle(fontSize: 19),),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(trailing, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('Date: $date', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

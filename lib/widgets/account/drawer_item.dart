import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback func;

  DrawerItem({
    required this.name,
    required this.icon,
    required this.func,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: func,
      icon: Icon(icon),
      label: FittedBox(
        child: Text(name),
      ),
      style: ElevatedButton.styleFrom(
        primary: name == 'アカウント削除'
            ? Theme.of(context).errorColor
            : Theme.of(context).accentColor,
      ),
    );
  }
}

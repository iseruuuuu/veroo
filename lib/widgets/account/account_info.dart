import 'package:flutter/material.dart';

class AccountInfo extends StatelessWidget {
  final String name;
  final String university;
  final int grade;
  final String image;

  AccountInfo(this.name, this.university, this.grade, this.image);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(10),
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '$university\n$grade年',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }
}

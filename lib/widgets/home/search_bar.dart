import 'package:flutter/material.dart';

import '../../screens/search/advanced_search_screen.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: OutlinedButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(AdvancedSearchScreen.routeName),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide(width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '検索',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              Icon(
                Icons.search,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../screens/search/advanced_search_screen.dart';

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      sliver: SliverAppBar(
        backgroundColor: Colors.transparent,
        title: OutlinedButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(AdvancedSearchScreen.routeName),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '...で検索',
                style: TextStyle(
                  fontSize: 20,
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

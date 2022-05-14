import 'package:flutter/material.dart';

import '../../screens/search/search_results_screen.dart';

class SearchBarWithQueries extends StatefulWidget {
  final Set<String> queries;

  SearchBarWithQueries(this.queries);

  @override
  State<SearchBarWithQueries> createState() => _SearchBarWithQueriesState();
}

class _SearchBarWithQueriesState extends State<SearchBarWithQueries> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: widget.queries
                  .map((q) => Container(
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 5,
                        ),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              widget.queries.remove(q);
                            });
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                q.split(':')[1],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.clear,
                                color: Colors.black,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          IconButton(
            onPressed: () => widget.queries.isEmpty
                ? null
                : Navigator.of(context).pushNamed(SearchResultsScreen.routeName,
                    arguments: widget.queries),
            icon: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../widgets/search/search_bar_with_queries.dart';
import '../../configs/genre.dart';

class AdvancedSearchScreen extends StatefulWidget {
  static const routeName = '/advanced-search';

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  Set<String> queries = {};

  @override
  Widget build(BuildContext context) {
    Widget _queryList(List<String> list) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: list
              .map((q) => Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          queries.add(q);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        primary: Colors.yellowAccent,
                        elevation: 10,
                      ),
                      child: Text(
                        q.split(':')[1],
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 50,
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 90,
                child: SearchBarWithQueries(queries),
              ),
              _queryList(area),
              Divider(
                thickness: 1.5,
                color: Colors.grey.shade400,
              ),
              _queryList(genre),
              Divider(
                thickness: 1.5,
                color: Colors.grey.shade400,
              ),
              _queryList(price),
              Divider(
                thickness: 1.5,
                color: Colors.grey.shade400,
              ),
              _queryList(scene),
              Divider(
                thickness: 1.5,
                color: Colors.grey.shade400,
              ),
              _queryList(keyword),
            ],
          ),
        ),
      ),
    );
  }
}

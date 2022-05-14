import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'search_results_detail_screen.dart';
import '../../widgets/menu/menu_grid_item.dart';

class SearchResultsScreen extends StatelessWidget {
  static const routeName = '/search-results';

  Future<List> _Searching(Set<String> queries) async {
    List results = [];
    Set results_ids = {};

    for (String q in queries) {
      final String key = q.split(':')[0];
      final String value = q.split(':')[1];

      var tmp;
      if (key == 'price') {
        if (value != '10000~') {
          final int price = int.parse(value.replaceFirst('~', ''));
          tmp = await FirebaseFirestore.instance
              .collection('menus')
              .where(key, isLessThanOrEqualTo: price)
              .get();
        } else {
          tmp = await FirebaseFirestore.instance
              .collection('menus')
              .where(key, isGreaterThanOrEqualTo: 10000)
              .get();
        }
      } else if (key == 'area') {
        tmp = await FirebaseFirestore.instance
            .collection('menus')
            .where(key, isEqualTo: value)
            .get();
      } else {
        tmp = await FirebaseFirestore.instance
            .collection('menus')
            .where(key, arrayContains: value)
            .get();
      }

      final List<String> ids = [];
      tmp.docs.forEach((doc) {
        ids.add(doc.id);
      });
      for (int i = 0; i < ids.length; i++) {
        if (!results_ids.contains(ids[i])) {
          results.add(tmp.docs[i]);
        }
      }
      results_ids.addAll(ids);
    }
    results.shuffle();
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final queries = ModalRoute.of(context)!.settings.arguments as Set<String>;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        future: _Searching(queries),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final results = snapshot.data;
            return results.isEmpty
                ? Center(
                    child: Text(
                      '該当メニューなし',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: results.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed(
                          SearchResultsDetailScreen.routeName,
                          arguments: {
                            'menus': results,
                            'index': index,
                            'fromSearchPage': true,
                          },
                        ),
                        child: MenuGridItem(results[index]['images']),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                  );
          }
        },
      ),
    );
  }
}

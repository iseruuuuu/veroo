import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../menu/menu_grid_item.dart';
import '../../screens/search/search_results_detail_screen.dart';

class TabBarPage extends StatefulWidget {
  final List<dynamic> menuIds;

  TabBarPage(this.menuIds);

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage> {
  List results = [];

  Future<void> _getMenuData() async {
    if (widget.menuIds.isNotEmpty && results.isEmpty) {
      widget.menuIds.forEach((id) {
        FirebaseFirestore.instance
            .collection('menus')
            .doc(id)
            .get()
            .then((DocumentSnapshot snapshot) {
          setState(() {
            results.add({
              'id': id,
              'images': snapshot.get('images'),
              'restaurant': snapshot.get('restaurant'),
              'name': snapshot.get('name'),
              'price': snapshot.get('price'),
              'coupon': snapshot.get('coupon'),
              'calorie': snapshot.get('calorie'),
            });
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getMenuData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (widget.menuIds.isEmpty) {
          return Center(
            child: Text(
              'メニューなし',
              style: TextStyle(
                fontSize: 30,
                color: Colors.grey,
              ),
            ),
          );
        } else if (widget.menuIds.isNotEmpty && results.isEmpty) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return GridView.builder(
            itemCount: results.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(
                  SearchResultsDetailScreen.routeName,
                  arguments: {
                    'menus': results,
                    'index': index,
                    'fromSearchPage': false,
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
    );
  }
}

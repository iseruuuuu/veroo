import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../screens/search/search_results_detail_screen.dart';

class MenuList extends StatelessWidget {
  List<dynamic> menuIds;
  List<dynamic> takeoutMenuIds;
  List<Map<String, dynamic>> menus = [];
  List<Map<String, dynamic>> takeoutMenus = [];

  MenuList(this.menuIds, this.takeoutMenuIds);

  final _formatter = NumberFormat("#,###");

  @override
  Widget build(BuildContext context) {
    Widget _listTile(int index, String name, int price, bool takeout) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
          SearchResultsDetailScreen.routeName,
          arguments: {
            'menus': takeout ? takeoutMenus : menus,
            'index': index,
            'fromSearchPage': false,
          },
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: 15,
            left: 40,
            right: 40,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 7,
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "￥${_formatter.format(price)}",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _list(List<dynamic> ids, bool takeout) {
      return ids.length == 0
          ? Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'メニューがありません',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.separated(
              itemCount: ids.length,
              itemBuilder: (BuildContext context, int index) {
                if (menus.isNotEmpty && !takeout) {
                  return _listTile(
                    index,
                    menus[index]['name'],
                    menus[index]['price'],
                    takeout,
                  );
                } else if (takeoutMenus.isNotEmpty && takeout) {
                  return _listTile(
                    index,
                    takeoutMenus[index]['name'],
                    takeoutMenus[index]['price'],
                    takeout,
                  );
                } else {
                  return FutureBuilder(
                    future: FirebaseFirestore.instance
                        .collection('menus')
                        .doc(ids[index])
                        .get(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(height: 35);
                      } else {
                        final Map<String, dynamic> info = {
                          'id': snapshot.data.id,
                          'name': snapshot.data['name'],
                          'price': snapshot.data['price'],
                          'images': snapshot.data['images'],
                          'restaurant': snapshot.data['restaurant'],
                          'coupon': snapshot.data['coupon'],
                          'calorie': snapshot.data['calorie'],
                        };
                        if (takeout) {
                          takeoutMenus.add(info);
                        } else {
                          menus.add(info);
                        }
                        return _listTile(
                          index,
                          snapshot.data['name'],
                          snapshot.data['price'],
                          takeout,
                        );
                      }
                    },
                  );
                }
              },
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(color: Colors.black),
            );
    }

    return DefaultTabController(
      length: 2,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        width: double.infinity,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
              child: TabBar(
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.blueGrey,
                      width: 2,
                    ),
                  ),
                ),
                tabs: <Widget>[
                  Text(
                    'メニュー',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'テイクアウトメニュー',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _list(menuIds, false),
                  _list(takeoutMenuIds, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

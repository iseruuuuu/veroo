import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../widgets/menu/menu_detail_item.dart';

class SearchResultsDetailScreen extends StatelessWidget {
  static const routeName = '/search-results-detail';

  final itemController = ItemScrollController();

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map;

    WidgetsBinding.instance!.addPostFrameCallback(
        (_) => itemController.jumpTo(index: data['index']));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ScrollablePositionedList.builder(
        itemCount: data['menus'].length,
        itemScrollController: itemController,
        itemBuilder: (BuildContext context, int index) {
          return MenuDetailItem(
            data['fromSearchPage']
                ? data['menus'][index].id
                : data['menus'][index]['id'],
            data['menus'][index]['images'],
            data['menus'][index]['restaurant'],
            data['menus'][index]['name'],
            data['menus'][index]['price'],
            data['menus'][index]['coupon'],
            data['menus'][index]['calorie'],
          );
        },
      ),
    );
  }
}

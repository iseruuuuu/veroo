import 'package:flutter/material.dart';

import '../models/content_list.dart';

class ContentLists with ChangeNotifier {
  List<ContentList> _contentList = [
    ContentList(
      id: 'aaa',
      listTitle: '今週の人気',
      postIds: [],
    ),
    ContentList(
      id: 'bbb',
      listTitle: '編集部のおすすめ',
      postIds: [],
    ),
    ContentList(
      id: 'ccc',
      listTitle: 'アンバサダーコンテンツ',
      postIds: [],
    ),
    ContentList(
      id: 'ddd',
      listTitle: '場所',
      postIds: [],
    ),
    ContentList(
      id: 'eee',
      listTitle: 'ジャンル',
      postIds: [],
    ),
  ];

  List<ContentList> get items {
    return [..._contentList];
  }

  ContentList findById(String id) {
    return _contentList.firstWhere((list) => list.id == id);
  }

  void addContentList(ContentList newContentList) {
    _contentList.add(newContentList);
    notifyListeners();
  }

  void updateContentList(ContentList newContentList) {
    final int index =
        _contentList.indexWhere((list) => list.id == newContentList.id);
    if (index >= 0) {
      _contentList[index] = newContentList;
      notifyListeners();
    } else {
      print('index error... in content_lists.dart');
    }
  }

  void deleteContentList(String id) {
    _contentList.removeWhere((list) => list.id == id);
    notifyListeners();
  }

  void reorderLists(int oldIndex, int newIndex) {
    _contentList.insert(newIndex, _contentList[oldIndex]);
    _contentList.removeAt(oldIndex > newIndex ? oldIndex + 1 : oldIndex);
    notifyListeners();
  }
}

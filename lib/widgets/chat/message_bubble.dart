import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/menu/menu_grid_item.dart';
import '../../screens/search/search_results_detail_screen.dart';

class MessageBubble extends StatelessWidget {
  final Key key;
  final String content;
  final bool isMe;
  final String timestamp;
  final String datestamp;
  final bool showDatestamp;
  final bool isRead;
  final String type;

  MessageBubble({
    required this.key,
    required this.content,
    required this.isMe,
    required this.timestamp,
    required this.datestamp,
    required this.showDatestamp,
    required this.isRead,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Widget _renderContent() {
      if (type == 'menu') {
        return Container(
          margin: const EdgeInsets.all(5),
          height: 170,
          width: 170,
          child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('menus')
                .doc(content)
                .get(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                try {
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(
                      SearchResultsDetailScreen.routeName,
                      arguments: {
                        'menus': [snapshot.data],
                        'index': 0,
                        'fromSearchPage': true,
                      },
                    ),
                    child: MenuGridItem(
                      snapshot.data['images'],
                    ),
                  );
                } catch (_) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/post_item_placeholder.png',
                      fit: BoxFit.cover,
                    ),
                  );
                }
              }
            },
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            color: isMe ? Theme.of(context).accentColor : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
              bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 7,
            horizontal: 13,
          ),
          margin: const EdgeInsets.all(5),
          constraints: BoxConstraints(maxWidth: 200),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        );
      }
    }

    return Column(
      children: <Widget>[
        if (showDatestamp)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.symmetric(
                  vertical: 1,
                  horizontal: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  datestamp,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                _renderContent(),
                Positioned(
                  left: isMe ? -25 : null,
                  right: isMe ? null : -25,
                  bottom: 5,
                  child: Column(
                    children: <Widget>[
                      if (isMe)
                        Text(
                          isRead ? 'Read' : '',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      Text(
                        timestamp,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

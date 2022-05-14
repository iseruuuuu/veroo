import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/friends.dart';

class ShareMenuToFriend extends StatelessWidget {
  final String menuId;

  ShareMenuToFriend(this.menuId);

  @override
  Widget build(BuildContext context) {
    Future<String> _findChatRoom(String uid) async {
      final snapshot =
          await FirebaseFirestore.instance.collection('chatRooms').where(
        'users',
        arrayContainsAny: [FirebaseAuth.instance.currentUser!.uid],
      ).get();
      String roomId = '';
      snapshot.docs.forEach((room) {
        if (room['users'].contains(uid)) {
          roomId = room.id;
        }
      });
      return roomId;
    }

    void _shareMenu(String uid) async {
      String roomId = await _findChatRoom(uid);

      if (roomId.isEmpty) {
        final roomRef =
            await FirebaseFirestore.instance.collection('chatRooms').add({
          'users': [
            FirebaseAuth.instance.currentUser!.uid,
            uid,
          ],
          'lastMessage': {
            'content': '',
            'timestamp': Timestamp.now(),
          },
          'number_of_unread': {
            FirebaseAuth.instance.currentUser!.uid: 0,
            uid: 0,
          }
        });
        roomId = roomRef.id;
      }

      final Timestamp timestamp = Timestamp.now();
      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .add({
        'content': menuId,
        'createdAt': timestamp,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'read': false,
        'type': 'menu',
      });
      final snapshot = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(roomId)
          .get();
      final numberOfUnread = snapshot.data()!['number_of_unread'];
      final users = snapshot.data()!['users'];
      users.remove(FirebaseAuth.instance.currentUser!.uid);
      final friend = users[0];
      numberOfUnread[friend] += 1;
      FirebaseFirestore.instance.collection('chatRooms').doc(roomId).update({
        'lastMessage': {
          'content': 'メニューを共有しました',
          'timestamp': timestamp,
        },
        'number_of_unread': numberOfUnread,
      });

      FirebaseFirestore.instance
          .collection('menus')
          .doc(menuId)
          .update({'share': FieldValue.increment(1)});
    }

    void _checkIfShare(String uid, String name) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('$nameさんにこのメニューを共有しますか？'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _shareMenu(uid);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('メニューを共有しました')));
              },
              child: Text('はい'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('いいえ'),
            )
          ],
        ),
      );
    }

    return Container(
      height: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              'ポストを友達に共有',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: Provider.of<Friends>(context, listen: false)
                  .fetchAndSetFriends(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                final friends = Provider.of<Friends>(context).friends;
                return friends.isEmpty
                    ? Center(
                        child: Text(
                          '共有する友達がいません',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: friends.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: GestureDetector(
                              onTap: () => _checkIfShare(
                                  friends[index].uid, friends[index].name),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(
                                  'assets/images/user_image_placeholder.jpg',
                                ),
                                foregroundImage: CachedNetworkImageProvider(
                                  friends[index].imageUrl,
                                ),
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

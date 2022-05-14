import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../widgets/search/search_user.dart';
import '../../providers/friends.dart';

class FollowAndFollowerScreen extends StatelessWidget {
  static const routeName = '/follow-and-follower';

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    void _checkIfDelete(String uid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('本当に削除しますか？'),
            actions: [
              TextButton(
                onPressed: () {
                  Provider.of<Friends>(
                    context,
                    listen: false,
                  ).deleteFriend(uid);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('友達を削除しました'),
                    ),
                  );
                },
                child: Text(
                  'はい',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'いいえ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    Widget _listTile(String uid, String imageUrl, String name) {
      return ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          maxRadius: 30,
          backgroundImage:
              AssetImage('assets/images/user_image_placeholder.jpg'),
          foregroundImage: NetworkImage(imageUrl),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_forever,
            color: Colors.red,
            size: 30,
          ),
          onPressed: () => _checkIfDelete(uid),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            onPressed: () async {
              final userData =
                  await FirebaseFirestore.instance.collection('users').get();
              List users = [];
              userData.docs.forEach((user) {
                if (user.id != uid) {
                  users.add(user);
                }
              });
              final myData = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get();
              final blockedUsers = myData.get('blocked_users');
              showSearch(
                context: context,
                delegate: SearchUser(
                  users,
                  blockedUsers,
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: FutureBuilder(
        future:
            Provider.of<Friends>(context, listen: false).fetchAndSetFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final friends = Provider.of<Friends>(context).friends;
            final List<Widget> listContent = <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Text(
                          'あなたのID',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            border: Border.all(
                              color: Colors.black,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            uid,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                ] +
                friends
                    .map((friend) => _listTile(
                          friend.uid,
                          friend.imageUrl,
                          friend.name,
                        ))
                    .toList();
            return Column(
              children: listContent,
            );
          }
        },
      ),
    );
  }
}

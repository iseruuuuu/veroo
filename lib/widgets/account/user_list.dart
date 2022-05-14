import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserList extends StatelessWidget {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  final String label;

  UserList(this.label);

  @override
  Widget build(BuildContext context) {
    void _unfollow(String userId) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text('フォローを解除しますか？'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseFirestore.instance.collection('users').doc(uid).update({
                  'follows': FieldValue.arrayRemove([userId])
                });
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'followers': FieldValue.arrayRemove([uid])
                });
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Theme.of(context).errorColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final users = snapshot.data[label];
          return users.isEmpty
              ? Center(
                  child: Text(
                    'No $label',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.grey.shade500,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(users[index])
                          .snapshots(),
                      builder:
                          (BuildContext context, AsyncSnapshot userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else {
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage(
                                  'assets/images/user_image_placeholder.jpg'),
                              foregroundImage: CachedNetworkImageProvider(
                                userSnapshot.data['image_url'],
                              ),
                            ),
                            title: Text('${userSnapshot.data['username']}'),
                            trailing: label == 'follows'
                                ? TextButton(
                                    child: Text(
                                      'フォロー解除',
                                      style: TextStyle(
                                        color: Theme.of(context).errorColor,
                                      ),
                                    ),
                                    onPressed: () => _unfollow(users[index]),
                                  )
                                : null,
                          );
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(
                    thickness: 1,
                  ),
                );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowUserModal extends StatelessWidget {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    List<dynamic> _follows = [];
    List<dynamic> _followers = [];

    void _toggleFollow(String friendId) async {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();
      final data = snapshot.data() as Map<String, dynamic>;
      _followers = data['followers'];
      if (_follows.contains(friendId)) {
        _follows.remove(friendId);
        _followers.remove(_uid);
      } else {
        _follows.add(friendId);
        _followers.add(_uid);
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .update({'follows': _follows});
      FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .update({'followers': _followers});
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('username')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final users = snapshot.data.docs;
          final me = users.firstWhere((user) => user.id == _uid);
          _follows = me['follows'];
          users.removeWhere((user) => user.id == _uid);
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: users.isEmpty
                ? Center(
                    child: Text(
                      'ユーザーなし',
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
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage(
                              'assets/images/user_image_placeholder.jpg'),
                          foregroundImage:
                              NetworkImage(users[index]['image_url']),
                        ),
                        title: Text(users[index]['username']),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.person_add_alt,
                            color: _follows.contains(users[index].id)
                                ? Theme.of(context).accentColor
                                : null,
                          ),
                          onPressed: () => _toggleFollow(users[index].id),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(
                      thickness: 1,
                    ),
                  ),
          );
        }
      },
    );
  }
}

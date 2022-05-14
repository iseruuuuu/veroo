import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserIcon extends StatelessWidget {
  final String userId;

  UserIcon(this.userId);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 60,
            width: 60,
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(5),
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: <Widget>[
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    backgroundImage: AssetImage(
                      'assets/images/user_image_placeholder.jpg',
                    ),
                    foregroundImage: CachedNetworkImageProvider(
                      snapshot.data['image_url'],
                    ),
                  ),
                ),
                if (snapshot.data['inCampus'])
                  CircleAvatar(
                    backgroundColor: Colors.lightGreenAccent,
                    radius: 7,
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommentListTile extends StatelessWidget {
  final String userId;
  final String comment;

  CommentListTile({
    required this.userId,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black54,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(
                  'assets/images/user_image_placeholder.jpg',
                ),
                foregroundImage: CachedNetworkImageProvider(
                  snapshot.data['image_url'],
                ),
              ),
              title: Text(snapshot.data['username']),
              subtitle: Text(comment),
            ),
          );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/menu/comment_list_tile.dart';
import '../../widgets/menu/comment_form.dart';

class CommentList extends StatelessWidget {
  final String menuId;

  CommentList({required this.menuId});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.6,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('menus')
              .doc(menuId)
              .collection('comments')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            List<dynamic> comments = [];
            try {
              comments = snapshot.data.docs;
            } catch (_) {
              null;
            }
            return ListView.builder(
              itemCount: comments.length + 1,
              itemBuilder: (BuildContext context, int index) => index == 0
                  ? Column(
                      children: <Widget>[
                        CommentForm(menuId: menuId),
                        if (comments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Text(
                              'コメントはまだありません',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    )
                  : CommentListTile(
                      userId: comments[index - 1]['userId'],
                      comment: comments[index - 1]['comment'],
                    ),
            );
          },
        ),
      ),
    );
  }
}

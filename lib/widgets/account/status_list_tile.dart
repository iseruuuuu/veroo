import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'user_icon.dart';
import '../../configs/emojis.dart';

class StatusListTile extends StatelessWidget {
  final String uid;
  final String name;
  final bool isMe;

  StatusListTile(this.uid, this.name, this.isMe);

  @override
  Widget build(BuildContext context) {
    void _save(String id, String text) {
      final statusRef =
          FirebaseFirestore.instance.collection('statuses').doc(id);
      final Timestamp timestamp = Timestamp.now();
      statusRef.update({'count': FieldValue.increment(1)});
      statusRef.collection('history').add({
        'user': uid,
        'savedAt': timestamp,
      });

      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'status': {
          'text': text,
          'savedAt': timestamp,
        }
      });

      Navigator.of(context).pop();
    }

    void _selectStatus() async {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder(
            future: FirebaseFirestore.instance.collection('statuses').get(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else {
                final statuses = snapshot.data.docs;
                return ListView.separated(
                  itemCount: statuses.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TextButton(
                      onPressed: () =>
                          _save(statuses[index].id, statuses[index]['text']),
                      child: Text.rich(
                        TextSpan(
                          children: <InlineSpan>[
                            TextSpan(
                              text: emojis[statuses[index]['text']],
                              style: TextStyle(fontSize: 20),
                            ),
                            TextSpan(
                              text: statuses[index]['text'],
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(color: Colors.black);
                  },
                );
              }
            },
          );
        },
      );
    }

    Widget _status(String text) {
      return Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: emojis[text],
              style: TextStyle(fontSize: 25),
            ),
            TextSpan(
              text: text != '' ? text : '未設定',
              style: TextStyle(fontWeight: FontWeight.bold),
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
          return Container();
        } else {
          return ListTile(
            leading: UserIcon(uid),
            title: isMe ? _status(snapshot.data['status']['text']) : Text(name),
            subtitle: isMe ? null : _status(snapshot.data['status']['text']),
            trailing: isMe
                ? IconButton(
                    onPressed: _selectStatus,
                    icon: Icon(Icons.edit),
                  )
                : snapshot.data['status']['text'] != ''
                    ? Text(DateFormat('HH:mm')
                        .format(snapshot.data['status']['savedAt'].toDate())
                        .toString())
                    : null,
          );
        }
      },
    );
  }
}

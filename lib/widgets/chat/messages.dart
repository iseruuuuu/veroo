import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'message_bubble.dart';

class Messages extends StatelessWidget {
  final String roomId;

  Messages(this.roomId);

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  String _getTime(DateTime dt) {
    return DateFormat('HH:mm').format(dt).toString();
  }

  String _getDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (DateTime(dt.year, dt.month, dt.day) == today) {
      return '今日';
    } else if (DateTime(dt.year, dt.month, dt.day) == yesterday) {
      return '昨日';
    } else if (DateTime(dt.year) == DateTime(now.year)) {
      return DateFormat('MM/dd EE').format(dt).toString();
    } else {
      return DateFormat('yyyy/MM/dd EE').format(dt).toString();
    }
  }

  bool _showDatetimeOrNot(DateTime dt, DateTime tmp) {
    if (DateTime(dt.year, dt.month, dt.day) !=
        DateTime(tmp.year, tmp.month, tmp.day)) {
      return true;
    } else {
      return false;
    }
  }

  void _setMessageAsRead(bool readFlag, String userId, String messageId) async {
    if (!readFlag && (userId != uid)) {
      FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .doc(messageId)
          .update({'read': true});
      final snapshot = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(roomId)
          .get();
      final numberOfUnread = snapshot.data()!['number_of_unread'];
      numberOfUnread[uid] = 0;
      FirebaseFirestore.instance.collection('chatRooms').doc(roomId).update({
        'number_of_unread': numberOfUnread,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final chatDocs = snapshot.data.docs;
          return ListView.builder(
            reverse: true,
            itemCount: chatDocs.length,
            itemBuilder: (BuildContext context, int index) {
              _setMessageAsRead(
                chatDocs[index]['read'],
                chatDocs[index]['userId'],
                chatDocs[index].id,
              );
              final DateTime dateTime = chatDocs[index]['createdAt'].toDate();
              final DateTime dateTimeToBeCompared =
                  (index + 1) < chatDocs.length
                      ? chatDocs[index + 1]['createdAt'].toDate()
                      : DateTime(2001);
              return MessageBubble(
                key: ValueKey(chatDocs[index].id),
                content: chatDocs[index]['content'],
                isMe: chatDocs[index]['userId'] == uid,
                timestamp: _getTime(dateTime),
                datestamp: _getDate(dateTime),
                showDatestamp:
                    _showDatetimeOrNot(dateTime, dateTimeToBeCompared),
                isRead: chatDocs[index]['read'],
                type: chatDocs[index]['type'],
              );
            },
          );
        }
      },
    );
  }
}

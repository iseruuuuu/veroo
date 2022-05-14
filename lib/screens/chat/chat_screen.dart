import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

import '../../widgets/chat/conversation_list.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  List blockedUsers = [];

  String _getTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour,
            dateTime.minute) ==
        DateTime(now.year, now.month, now.day, now.hour, now.minute)) {
      return '今';
    } else if (DateTime(dateTime.year, dateTime.month, dateTime.day) == today) {
      return DateFormat('HH:mm').format(dateTime).toString();
    } else if (DateTime(dateTime.year, dateTime.month, dateTime.day) ==
        yesterday) {
      return '昨日';
    } else if (DateTime(dateTime.year) == DateTime(now.year)) {
      return DateFormat('MM/dd').format(dateTime).toString();
    } else {
      return DateFormat('yyyy/MM/dd').format(dateTime).toString();
    }
  }

  @override
  void initState() {
    // final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // messaging.requestPermission(
    //   alert: true,
    //   announcement: false,
    //   badge: true,
    //   carPlay: false,
    //   criticalAlert: false,
    //   provisional: false,
    //   sound: true,
    // );

    _loadBlockedUsers();

    super.initState();
  }

  void _loadBlockedUsers() async {
    final myData =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    blockedUsers = myData.get('blocked_users');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'チャット',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chatRooms')
            .where(
              'users',
              arrayContains: uid,
            )
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List chatRooms = [];
            snapshot.data.docs.forEach((room) {
              final friendId = room['users'].firstWhere((id) => id != uid);
              if (!blockedUsers.contains(friendId)) {
                chatRooms.add(room);
              }
            });

            return chatRooms.isEmpty
                ? Center(
                    child: Text(
                      'チャットなし',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: chatRooms.length,
                    itemBuilder: (BuildContext context, int index) {
                      final friendId = chatRooms[index]['users']
                          .firstWhere((id) => id != uid);
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(friendId)
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot friendSnapshot) {
                          if (friendSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else {
                            final content =
                                chatRooms[index]['lastMessage']['content'];
                            return ConversationList(
                              roomId: chatRooms[index].id,
                              name: friendSnapshot.data['username'],
                              messageText: content,
                              imageUrl: friendSnapshot.data['image_url'],
                              time: content.isEmpty
                                  ? ''
                                  : _getTime(chatRooms[index]['lastMessage']
                                          ['timestamp']
                                      .toDate()),
                              numberOfUnread: chatRooms[index]
                                  ['number_of_unread'][uid],
                            );
                          }
                        },
                      );
                    },
                  );
          }
        },
      ),
    );
  }
}

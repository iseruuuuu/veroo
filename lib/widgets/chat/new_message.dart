import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  final String roomId;

  NewMessage(this.roomId);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _controller = TextEditingController();
  String _enteredMessage = '';

  void _sendMessage() async {
    final Timestamp timestamp = Timestamp.now();
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.roomId)
        .collection('messages')
        .add({
      'content': _enteredMessage.trim(),
      'createdAt': timestamp,
      'userId': _uid,
      'read': false,
      'type': 'text',
    });
    final snapshot = await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.roomId)
        .get();
    final numberOfUnread = snapshot.data()!['number_of_unread'];
    final users = snapshot.data()!['users'];
    users.remove(_uid);
    final friend = users[0];
    numberOfUnread[friend] += 1;
    FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(widget.roomId)
        .update({
      'lastMessage': {
        'content': _enteredMessage.trim(),
        'timestamp': timestamp,
      },
      'number_of_unread': numberOfUnread,
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 60,
      width: double.infinity,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "メッセージを入力...",
                hintStyle: TextStyle(color: Colors.black54),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
            icon: Icon(Icons.send),
            color: Theme.of(context).accentColor,
          ),
        ],
      ),
    );
  }
}

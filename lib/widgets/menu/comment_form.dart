import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentForm extends StatefulWidget {
  final String menuId;

  CommentForm({required this.menuId});

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final _controller = TextEditingController();
  String _enteredMessage = '';

  void _saveComment() {
    FocusScope.of(context).unfocus();
    FirebaseFirestore.instance
        .collection('menus')
        .doc(widget.menuId)
        .collection('comments')
        .add({
      'createdAt': Timestamp.now(),
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'comment': _enteredMessage.trim(),
    });
    setState(() {
      _enteredMessage = '';
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "コメント記入",
                hintStyle: TextStyle(color: Colors.black54),
              ),
              onChanged: (value) {
                setState(() {
                  _enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            onPressed: _enteredMessage.trim().isEmpty ? null : _saveComment,
            icon: Icon(Icons.send),
            color: Theme.of(context).accentColor,
          ),
        ],
      ),
    );
  }
}

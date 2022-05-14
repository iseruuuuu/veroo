import 'package:flutter/material.dart';

class ChatUser {
  String name;
  String messageText;
  String imageURL;
  String time;

  ChatUser({
    required this.name,
    required this.messageText,
    required this.imageURL,
    required this.time,
  });
}

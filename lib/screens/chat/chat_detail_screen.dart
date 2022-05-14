import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../widgets/chat/new_message.dart';
import '../../widgets/chat/messages.dart';

class ChatDetailScreen extends StatefulWidget {
  static const routeName = '/chat-detail-screen';

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String roomId = data['roomId'];
    final String name = data['name'];
    final String imageUrl = data['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 2,
              ),
              CircleAvatar(
                backgroundImage:
                    AssetImage('assets/images/user_image_placeholder.jpg'),
                foregroundImage: CachedNetworkImageProvider(imageUrl),
                maxRadius: 20,
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Messages(roomId),
              ),
              NewMessage(roomId),
            ],
          ),
        ),
      ),
    );
  }
}

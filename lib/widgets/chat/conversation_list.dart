import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../screens/chat/chat_detail_screen.dart';

class ConversationList extends StatelessWidget {
  final String roomId;
  final String name;
  final String messageText;
  final String imageUrl;
  final String time;
  final int numberOfUnread;

  ConversationList({
    required this.roomId,
    required this.name,
    required this.messageText,
    required this.imageUrl,
    required this.time,
    required this.numberOfUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed(
            ChatDetailScreen.routeName,
            arguments: {
              'roomId': roomId,
              'name': name,
              'imageUrl': imageUrl,
            },
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: AssetImage(
                          'assets/images/user_image_placeholder.jpg',
                        ),
                        foregroundImage: CachedNetworkImageProvider(imageUrl),
                        maxRadius: 30,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                name,
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 6),
                              Text(
                                messageText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  fontWeight: numberOfUnread == 0
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: numberOfUnread == 0
                          ? Colors.transparent
                          : Colors.black12,
                      child: Text(
                        numberOfUnread == 0 ? '' : numberOfUnread.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MenuGridItem extends StatelessWidget {
  final List<dynamic> images;

  MenuGridItem(this.images);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: <Widget>[
          CachedNetworkImage(
            placeholder: (BuildContext context, String s) => Image.asset(
              'assets/images/post_item_placeholder.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            imageUrl: images[0],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          if (images.length > 1)
            Positioned(
              top: 10,
              right: 10,
              child: Icon(
                Icons.filter_none,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

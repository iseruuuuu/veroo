import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../screens/restaurant/restaurant_detail_screen.dart';
import '../../screens/coupon/coupon_screen.dart';
import '../../widgets/menu/eat_button.dart';
import '../../widgets/menu/comment_list.dart';
import '../../widgets/menu/share_menu_to_friend.dart';

class MenuDetailItem extends StatefulWidget {
  final String menuId;
  final List<dynamic> images;
  final String restaurantId;
  final String menuName;
  final int price;
  final String couponId;
  final String calorie;

  MenuDetailItem(
    this.menuId,
    this.images,
    this.restaurantId,
    this.menuName,
    this.price,
    this.couponId,
    this.calorie,
  );

  @override
  State<MenuDetailItem> createState() => _MenuDetailItemState();
}

class _MenuDetailItemState extends State<MenuDetailItem> {
  final _formatter = NumberFormat("#,###");
  int _imageIndex = 0;
  String _restaurantName = '';
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    _isBookmarked =
        (userRef.data()!['bookmarkedMenus'] as List).contains(widget.menuId);
  }

  void _getRestaurantName() async {
    final restaurantRef = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.restaurantId)
        .get();
    setState(() {
      _restaurantName = restaurantRef.data()!['name'];
    });
  }

  void _toggleFavorite() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final menuRef =
        FirebaseFirestore.instance.collection('menus').doc(widget.menuId);

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    if (_isBookmarked) {
      userRef.update({
        'bookmarkedMenus': FieldValue.arrayUnion([widget.menuId])
      });
      menuRef.update({'bookmarks': FieldValue.increment(1)});
    } else {
      userRef.update({
        'bookmarkedMenus': FieldValue.arrayRemove([widget.menuId])
      });
      menuRef.update({'bookmarks': FieldValue.increment(-1)});
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => CommentList(menuId: widget.menuId),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _shareMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => ShareMenuToFriend(widget.menuId),
    );
  }

  @override
  Widget build(BuildContext context) {
    _getRestaurantName();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Stack(
              children: <Widget>[
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: widget.images.length == 1
                      ? PinchZoomImage(
                          image: SizedBox(
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: widget.images[0],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Image.asset(
                                  'assets/images/post_item_placeholder.png',
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) =>
                                    Center(child: Icon(Icons.error)),
                              ),
                            ),
                          ),
                        )
                      : CarouselSlider(
                          items: widget.images
                              .map(
                                (url) => PinchZoomImage(
                                  image: SizedBox(
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: url,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Image.asset(
                                          'assets/images/post_item_placeholder.png',
                                          fit: BoxFit.cover,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          options: CarouselOptions(
                            viewportFraction: 1,
                            initialPage: _imageIndex,
                            aspectRatio: 1,
                          ),
                        ),
                ),
                Positioned(
                  left: 5,
                  bottom: 5,
                  child: EatButton(widget.menuId),
                ),
                if (widget.calorie != '')
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                        ),
                      ),
                      child: Text(
                        widget.calorie,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_outline),
                ),
                IconButton(
                  onPressed: _showComments,
                  icon: Icon(Icons.chat_bubble_outline),
                ),
                IconButton(
                  onPressed: _shareMenu,
                  icon: Icon(Icons.send_outlined),
                ),
                Spacer(),
                if (widget.couponId != '')
                  TextButton.icon(
                    onPressed: () async {
                      final couponData = await FirebaseFirestore.instance
                          .collection('coupons')
                          .doc(widget.couponId)
                          .get();
                      Navigator.of(context).pushNamed(
                        CouponScreen.routeName,
                        arguments: {
                          'id': widget.couponId,
                          'images': couponData.data()!['images'],
                          'restaurantName': _restaurantName,
                          'menuName': widget.menuName,
                          'text': couponData.data()!['text'],
                        },
                      );
                    },
                    icon: Icon(
                      Icons.confirmation_num_rounded,
                      color: Colors.orange,
                    ),
                    label: Text(
                      'クーポンあり',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(
                      RestaurantDetailScreen.routeName,
                      arguments: widget.restaurantId,
                    ),
                    child: Text(
                      _restaurantName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Text(
                          widget.menuName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '￥${_formatter.format(widget.price)}',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

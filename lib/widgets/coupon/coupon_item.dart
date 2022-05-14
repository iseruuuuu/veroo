import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../screens/coupon/coupon_screen.dart';

class CouponItem extends StatelessWidget {
  final String couponId;
  final bool recommendation;

  CouponItem(this.couponId, this.recommendation);

  List imageUrls = [];
  String restaurantName = '';
  String menuName = '';
  String text = '';

  Future<void> _getData() async {
    final couponData = await FirebaseFirestore.instance
        .collection('coupons')
        .doc(couponId)
        .get();
    imageUrls = couponData.data()!['images'];
    text = couponData.data()!['text'];

    final restaurantData = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(couponData.data()!['restaurant'])
        .get();
    restaurantName = restaurantData.data()!['name'];

    final menuData = await FirebaseFirestore.instance
        .collection('menus')
        .doc(couponData.data()!['menu'])
        .get();
    menuName = menuData.data()!['name'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else {
          return GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(
              CouponScreen.routeName,
              arguments: {
                'id': couponId,
                'images': imageUrls,
                'restaurantName': restaurantName,
                'menuName': menuName,
                'text': text,
              },
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.all(10),
              elevation: 10,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: recommendation ? 170 : 100,
                    width: recommendation ? 300 : 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: CachedNetworkImage(
                        placeholder: (BuildContext context, String s) =>
                            Image.asset(
                          'assets/images/post_item_placeholder.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        imageUrl: imageUrls[0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: recommendation ? 300 : 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            restaurantName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            menuName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

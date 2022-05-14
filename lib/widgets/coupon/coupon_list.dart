import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'coupon_item.dart';

class CouponList extends StatelessWidget {
  final List<String> area;

  CouponList(this.area);

  Future<QuerySnapshot> _getCouponData(bool recommendation) async {
    QuerySnapshot couponData;
    if (recommendation) {
      couponData = await FirebaseFirestore.instance
          .collection('coupons')
          .where('recommendation', isEqualTo: true)
          .get();
    } else {
      couponData = await FirebaseFirestore.instance
          .collection('coupons')
          .where('area', whereIn: area)
          .get();
    }
    return couponData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(5),
          width: double.infinity,
          child: Text(
            area[0] == 'recommendation'
                ? 'ここ行かないでどこ行くんだヨ！！'
                : area[0] + '・' + area[1],
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(
          height: area[0] == 'recommendation' ? 240 : 170,
          child: FutureBuilder(
            future: _getCouponData(area[0] == 'recommendation'),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else {
                final coupons = snapshot.data.docs;
                return coupons.isEmpty
                    ? Center(
                        child: Text(
                          'クーポンなし',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: coupons.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CouponItem(
                            coupons[index].id,
                            area[0] == 'recommendation',
                          );
                        },
                      );
              }
            },
          ),
        ),
      ],
    );
  }
}

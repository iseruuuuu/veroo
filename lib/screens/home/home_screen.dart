import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'status_screen.dart';
import '../../widgets/account/user_icon.dart';
import '../../widgets/home/user_location_list.dart';
import '../../widgets/home/search_bar.dart';
import '../../widgets/coupon/coupon_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List<dynamic> _blockedUsers = [];

  // void _getBlockedUsers() async {
  //   if (FirebaseAuth.instance.currentUser!.uid !=
  //       'Mucj7882asg7YQrvaXp4jqDbT5m1') {
  //     final data = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(FirebaseAuth.instance.currentUser!.uid)
  //         .get();
  //     _blockedUsers = data.data()!['blocked_users'];
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: UserIcon(FirebaseAuth.instance.currentUser!.uid),
        title: Text(
          'ホーム',
          style: TextStyle(
            // color: Theme.of(context).accentColor,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(StatusScreen.routeName),
            icon: Icon(
              Icons.stacked_bar_chart,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            UserLocationList(),
            Divider(thickness: 2),
            SearchBar(),
            Container(
              margin: EdgeInsets.all(5),
              width: double.infinity,
              child: Text(
                'クーポン',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            CouponList(['recommendation']),
            CouponList(['御茶ノ水', '神保町']),
            CouponList(['明大前', '下北沢']),
          ],
        ),
      ),
    );
  }
}

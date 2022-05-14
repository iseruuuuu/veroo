import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/account/drawer_list.dart';
import '../../widgets/account/account_info.dart';
import '../../widgets/account/tab_bar_page.dart';

class AccountScreen extends StatefulWidget {
  static const routeName = '/account';

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              centerTitle: false,
              backgroundColor: Theme.of(context).primaryColor,
              title: Text(
                snapshot.data['username'],
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 20,
                ),
              ),
            ),
            endDrawer: DrawerList(),
            body: Column(
              children: <Widget>[
                AccountInfo(
                  snapshot.data['username'],
                  snapshot.data['university'],
                  snapshot.data['grade'],
                  snapshot.data['image_url'],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TabBar(
                    unselectedLabelColor: Colors.black26,
                    labelColor: Colors.black,
                    indicator: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    controller: tabController,
                    tabs: <Widget>[
                      Tab(icon: Icon(Icons.bookmark)),
                      Tab(icon: Icon(Icons.restaurant)),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: TabBarView(
                      controller: tabController,
                      children: <Widget>[
                        TabBarPage(snapshot.data['bookmarkedMenus']),
                        TabBarPage(snapshot.data['eatenMenus']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

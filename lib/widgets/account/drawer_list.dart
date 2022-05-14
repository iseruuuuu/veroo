import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'drawer_item.dart';
import '../../screens/account/account_info_edit_screen.dart';
import '../../screens/account/follow_and_follower_screen.dart';
import '../../screens/account/privacy_and_policy.dart';

class DrawerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            '設定',
          ),
          leading: Container(),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
            vertical: 70,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DrawerItem(
                name: 'アカウント情報編集',
                icon: Icons.edit,
                func: () => Navigator.of(context).pushNamed(
                  AccountInfoEditScreen.routeName,
                  arguments: true,
                ),
              ),
              DrawerItem(
                name: 'ログアウト',
                icon: Icons.exit_to_app,
                func: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
              DrawerItem(
                name: 'フォロー＆フォロワー',
                icon: Icons.people_alt,
                func: () => Navigator.of(context)
                    .pushNamed(FollowAndFollowerScreen.routeName),
              ),
              DrawerItem(
                name: 'プライバシー＆ポリシー',
                icon: Icons.security,
                func: () =>
                    Navigator.of(context).pushNamed(PrivacyAndPolicy.routeName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

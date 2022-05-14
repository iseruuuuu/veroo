import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/account/status_list_tile.dart';
import '../../providers/friends.dart';

class StatusScreen extends StatelessWidget {
  static const routeName = '/status';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        future:
            Provider.of<Friends>(context, listen: false).fetchAndSetFriends(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          final friends = Provider.of<Friends>(context).friends;
          final List<Widget> statusList = [
                StatusListTile(
                  FirebaseAuth.instance.currentUser!.uid,
                  '',
                  true,
                ),
                Divider(color: Colors.black),
              ] +
              friends
                  .map((friend) => StatusListTile(
                        friend.uid,
                        friend.name,
                        false,
                      ))
                  .toList();
          return SingleChildScrollView(
            child: Column(children: statusList),
          );
        },
      ),
    );
  }
}

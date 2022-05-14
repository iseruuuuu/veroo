import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/friends.dart';
import '../account/user_icon.dart';

class UserLocationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: FutureBuilder(
        future:
            Provider.of<Friends>(context, listen: false).fetchAndSetFriends(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else {
            final friends = Provider.of<Friends>(context).friends;
            return friends.isEmpty
                ? Center(
                    child: Text(
                      '友達がいません',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: friends.length,
                    itemBuilder: (BuildContext context, int index) {
                      return UserIcon(friends[index].uid);
                    },
                  );
          }
        },
      ),
    );
  }
}

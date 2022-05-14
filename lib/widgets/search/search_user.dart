import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../providers/friends.dart';

class SearchUser extends SearchDelegate {
  final List users;
  final List blockedUsers;

  SearchUser(
    this.users,
    this.blockedUsers,
  );

  @override
  String? get searchFieldLabel => 'IDで検索';

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = '';
            }
          },
          icon: const Icon(Icons.clear),
        ),
      ];

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) {
    List suggestions = users.where((searchResult) {
      final result = searchResult.id.toLowerCase();
      final input = query.toLowerCase();

      return result.contains(input);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];

        return Slidable(
          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.3,
            children: [
              SlidableAction(
                onPressed: (context) async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${suggestion['username']}さんをフォローしました"),
                    ),
                  );
                  await Provider.of<Friends>(
                    context,
                    listen: false,
                  ).followUser(suggestion.id);
                },
                backgroundColor: Color(0xFF21B7CA),
                foregroundColor: Colors.white,
                icon: Icons.add,
                label: 'フォロー',
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.3,
            children: [
              SlidableAction(
                onPressed: blockedUsers.contains(suggestion.id)
                    ? (context) async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("${suggestion['username']}さんをブロック解除しました"),
                          ),
                        );
                        await Provider.of<Friends>(
                          context,
                          listen: false,
                        ).unBlockUser(suggestion.id);
                      }
                    : (context) async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("${suggestion['username']}さんをブロックしました"),
                          ),
                        );
                        await Provider.of<Friends>(
                          context,
                          listen: false,
                        ).blockUser(suggestion.id);
                      },
                backgroundColor: blockedUsers.contains(suggestion.id)
                    ? Color(0xFF7BC043)
                    : Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: blockedUsers.contains(suggestion.id)
                    ? Icons.autorenew
                    : Icons.block,
                label: blockedUsers.contains(suggestion.id) ? 'ブロック解除' : 'ブロック',
              ),
            ],
          ),
          child: Builder(
            builder: (context) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      AssetImage('assets/images/user_image_placeholder.jpg'),
                  foregroundImage: NetworkImage(suggestion['image_url']),
                ),
                title: Text(suggestion['username']),
                subtitle: Text('ID: ${suggestion.id}'),
                onTap: () {
                  final slidable = Slidable.of(context)!;
                  final isClosed =
                      slidable.actionPaneType.value == ActionPaneType.none;

                  if (isClosed) {
                    slidable.openStartActionPane();
                  } else {
                    slidable.close();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

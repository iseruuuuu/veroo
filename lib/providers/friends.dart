import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart' as user;

class Friends with ChangeNotifier {
  List<user.User> _friends = [];

  List<user.User> get friends {
    return [..._friends];
  }

  Future<void> fetchAndSetFriends() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    final userData = userSnapshot.data() as Map<String, dynamic>;
    final List<dynamic> follows = userData['follows'];
    final List<dynamic> followers = userData['followers'];
    final List<dynamic> friends =
        follows.toSet().intersection(followers.toSet()).toList();
    List<user.User> loadedUsers = [];
    for (int i = 0; i < friends.length; i++) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(friends[i])
          .get();
      final data = snapshot.data() as Map<String, dynamic>;
      loadedUsers.add(user.User(
        uid: snapshot.id,
        name: data['username'],
        imageUrl: data['image_url'],
      ));
    }
    _friends = loadedUsers;
    notifyListeners();
  }

  Future<void> blockUser(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'blocked_users': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> unBlockUser(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'blocked_users': FieldValue.arrayRemove([uid]),
    });
  }

  Future<void> followUser(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'follows': FieldValue.arrayUnion([uid]),
    });
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'followers':
          FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
    });
    await fetchAndSetFriends();
    _friends.forEach((friend) async {
      if (friend.uid == uid) {
        await FirebaseFirestore.instance.collection('chatRooms').add({
          'users': [
            FirebaseAuth.instance.currentUser!.uid,
            uid,
          ],
          'lastMessage': {
            'content': '',
            'timestamp': Timestamp.now(),
          },
          'number_of_unread': {
            FirebaseAuth.instance.currentUser!.uid: 0,
            uid: 0,
          }
        });
      }
    });
    notifyListeners();
  }

  Future<void> deleteFriend(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'follows': FieldValue.arrayRemove([uid])
    });
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'followers':
          FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
    });
    final chatRoomSnapshot = await FirebaseFirestore.instance
        .collection('chatRooms')
        .where('users', arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get();
    chatRoomSnapshot.docs.forEach((chatRoom) async {
      if (chatRoom['users'].contains(uid)) {
        await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(chatRoom.id)
            .delete();
      }
    });
    _friends.removeWhere((friend) => friend.uid == uid);
    notifyListeners();
  }

  user.User findById(String id) {
    return _friends.firstWhere(
      (friend) => friend.uid == id,
      orElse: () => user.User(
        uid: '',
        name: '',
        imageUrl: '',
      ),
    );
  }
}

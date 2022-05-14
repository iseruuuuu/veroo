import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post with ChangeNotifier {
  final String id;
  final String userId;
  final String friendId;
  final String restaurantName;
  final String restaurantId;
  final String area;
  final List<String> images;
  final Timestamp createdAt;
  final int price;
  final String atmosphere;
  final String feature;
  final String taste;
  final String comment;
  final String genre;

  Post({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.restaurantName,
    required this.restaurantId,
    required this.area,
    required this.images,
    required this.createdAt,
    required this.price,
    required this.atmosphere,
    required this.feature,
    required this.taste,
    required this.comment,
    required this.genre,
  });
}

class Posts with ChangeNotifier {
  Future<void> addPost(Post newPost) async {
    final DocumentReference postRef =
        await FirebaseFirestore.instance.collection('posts').add({
      'userId': newPost.userId,
      'friendId': newPost.friendId,
      'createdAt': newPost.createdAt,
      'images': [],
      'restaurantName': newPost.restaurantName,
      'restaurantId': newPost.restaurantId,
      'area': newPost.area,
      'genre': newPost.genre,
      'price': newPost.price,
      'atmosphere': newPost.atmosphere,
      'feature': newPost.feature,
      'taste': newPost.taste,
      'comment': newPost.comment,
      'usersOfFavorite': [],
    });
    List<String> imageUrls = [];
    final Reference imageDirRef =
        FirebaseStorage.instance.ref().child('posts').child(postRef.id);
    for (int i = 0; i < newPost.images.length; i++) {
      final imageRef = imageDirRef.child('${i + 1}.jpg');
      await imageRef.putFile(File(newPost.images[i]));
      final String url = await imageRef.getDownloadURL();
      imageUrls.add(url);
    }
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postRef.id)
        .update({'images': imageUrls});
    final DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(newPost.userId);
    List<String> newList = [postRef.id];
    final userData = await userRef.get();
    final Map<String, dynamic> data = userData.data() as Map<String, dynamic>;
    data['posts'].forEach((postId) => newList.add(postId));
    await userRef.update({'posts': newList});
  }

  Future<void> updatePost(Post newPost) async {
    final ListResult imageRef = await FirebaseStorage.instance
        .ref()
        .child('posts')
        .child(newPost.id)
        .listAll();
    imageRef.items.forEach((Reference url) async {
      await url.delete();
    });
    List<String> imageUrls = [];
    final Reference imageDirRef =
        FirebaseStorage.instance.ref().child('posts').child(newPost.id);
    for (int i = 0; i < newPost.images.length; i++) {
      final ref = imageDirRef.child('${i + 1}.jpg');
      await ref.putFile(File(newPost.images[i]));
      final String url = await ref.getDownloadURL();
      imageUrls.add(url);
    }
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(newPost.id)
        .update({
      'friendId': newPost.friendId,
      'images': imageUrls,
      'restaurantName': newPost.restaurantName,
      'restaurantId': newPost.restaurantId,
      'area': newPost.area,
      'genre': newPost.genre,
      'price': newPost.price,
      'atmosphere': newPost.atmosphere,
      'feature': newPost.feature,
      'taste': newPost.taste,
      'comment': newPost.comment,
    });
  }

  Future<void> deletePost(String id) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(id);

    // remove post's id and restaurant's id of the post from anyone who had that post as favorite
    final snapshot = await postRef.get();
    snapshot['usersOfFavorite'].forEach((userId) {
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'favorite_posts': FieldValue.arrayRemove([id]),
        'favorite_restaurants':
            FieldValue.arrayRemove([snapshot['restaurantId']]),
      });
    });

    // delete post
    await postRef.delete();

    // delete images
    final ListResult imageRef =
        await FirebaseStorage.instance.ref().child('posts').child(id).listAll();
    imageRef.items.forEach((Reference ref) => ref.delete());

    // remove post's id from "posts" array in user's doc
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'posts': FieldValue.arrayRemove([id]),
    });
  }
}

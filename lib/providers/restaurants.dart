import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant with ChangeNotifier {
  final id;
  final name;
  final description;
  final imageUrl;
  final location;
  final time;
  final phoneNumber;
  final genre;
  final area;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.time,
    required this.phoneNumber,
    required this.genre,
    required this.area,
  });
}

class Restaurants with ChangeNotifier {
  List<Restaurant> _restaurants = [];

  List<Restaurant> get restaurants {
    return [..._restaurants];
  }

  Future<void> fetchAndSetRestaurants() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .orderBy('name')
        .get();
    final resData = snapshot.docs;
    List<Restaurant> loadedRestaurants = [];
    resData.forEach((res) {
      loadedRestaurants.add(Restaurant(
        id: res.id,
        name: res['name'],
        description: res['description'],
        imageUrl: '',
        location: res['location'],
        time: res['time'],
        phoneNumber: res['phone'],
        genre: res['genre'],
        area: res['area'],
      ));
    });
    _restaurants = loadedRestaurants;
    notifyListeners();
  }

  Restaurant findById(String id) {
    return _restaurants.firstWhere(
      (restaurant) => restaurant.id == id,
      orElse: () => Restaurant(
        id: '',
        name: '',
        description: '',
        imageUrl: '',
        location: '',
        time: {},
        phoneNumber: '',
        genre: '',
        area: '',
      ),
    );
  }
}

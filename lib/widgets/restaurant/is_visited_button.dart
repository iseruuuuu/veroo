import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IsVisitedButton extends StatefulWidget {
  final String restaurantId;

  IsVisitedButton(this.restaurantId);

  @override
  State<IsVisitedButton> createState() => _IsVisitedButtonState();
}

class _IsVisitedButtonState extends State<IsVisitedButton> {
  bool _isVisited = false;

  @override
  void initState() {
    super.initState();
    _loadVisitData();
  }

  void _loadVisitData() async {
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      _isVisited = (data.data()!['visitedRestaurants'] as List)
          .contains(widget.restaurantId);
    });
  }

  void _toggleVisit() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    setState(() {
      _isVisited = !_isVisited;
    });

    if (_isVisited) {
      userRef.update({
        'visitedRestaurants': FieldValue.arrayUnion([widget.restaurantId])
      });
    } else {
      userRef.update({
        'visitedRestaurants': FieldValue.arrayRemove([widget.restaurantId])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(
        Icons.check,
        color: Colors.black,
      ),
      label: Text(
        '行った',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: _isVisited ? Colors.yellow : Colors.grey[300],
        shape: const StadiumBorder(),
      ),
      onPressed: _toggleVisit,
    );
  }
}

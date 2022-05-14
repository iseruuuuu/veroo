import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EatButton extends StatefulWidget {
  final String menuId;

  EatButton(this.menuId);

  @override
  State<EatButton> createState() => _EatButtonState();
}

class _EatButtonState extends State<EatButton> {
  bool _eat = false;

  @override
  void initState() {
    super.initState();
    _loadEatData();
  }

  void _loadEatData() async {
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      _eat = (data.data()!['eatenMenus'] as List).contains(widget.menuId);
    });
  }

  void _toggleEat() async {
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    setState(() {
      _eat = !_eat;
    });

    if (_eat) {
      userRef.update({
        'eatenMenus': FieldValue.arrayUnion([widget.menuId])
      });
    } else {
      userRef.update({
        'eatenMenus': FieldValue.arrayRemove([widget.menuId])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(
        Icons.local_dining_sharp,
        color: Colors.black,
      ),
      label: Text(
        '食べた',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: _eat ? Colors.yellow : Colors.grey[300],
        shape: const StadiumBorder(),
      ),
      onPressed: _toggleEat,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CouponButton extends StatefulWidget {
  final String couponId;

  CouponButton(this.couponId);

  @override
  State<CouponButton> createState() => _CouponButtonState();
}

class _CouponButtonState extends State<CouponButton> {
  @override
  Widget build(BuildContext context) {
    void _useThisCoupon() async {
      await FirebaseFirestore.instance
          .collection('coupons')
          .doc(widget.couponId)
          .update({
        'users': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'coupons': FieldValue.arrayUnion([widget.couponId])
      });
      Navigator.of(context).pop();
    }

    void _confirmDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('確認'),
            content: Text('このクーポンを今使用しますか？\n\n一度ボタンを押してしまうと二度と使用することはできません。'),
            actions: <Widget>[
              TextButton(
                child: Text(
                  '使用する',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _useThisCoupon,
              ),
              TextButton(
                child: Text('また今度'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('coupons')
          .doc(widget.couponId)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else {
          final bool _used = snapshot.data['users']
              .contains(FirebaseAuth.instance.currentUser!.uid);
          return ElevatedButton(
            child: const Text(
              '使用する',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(
                top: 15,
                bottom: 15,
                left: 40,
                right: 40,
              ),
              primary: Colors.yellow,
              onPrimary: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _used ? null : _confirmDialog,
          );
        }
      },
    );
  }
}

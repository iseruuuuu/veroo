import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _snackBarErrorMessageTemplate(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _submitAuthForm({
    required String email,
    required String password,
    required bool isLogin,
  }) async {
    setState(() {
      _isLoading = true;
    });
    UserCredential userCredential;
    if (isLogin) {
      try {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (e.code == 'user-not-found') {
          _snackBarErrorMessageTemplate('そのメールアドレスのユーザーが見つかりません');
        } else if (e.code == 'wrong-password') {
          _snackBarErrorMessageTemplate('パスワードが正しくありません');
        } else if (e.code == 'invalid-email') {
          _snackBarErrorMessageTemplate('無効なメールアドレスです');
        } else if (e.code == 'user-disabled') {
          _snackBarErrorMessageTemplate('そのユーザーは無効です');
        } else {
          _snackBarErrorMessageTemplate('ログインに失敗しました');
        }
      }
    } else {
      try {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'username': '',
          'image_url': '',
          'follows': [],
          'followers': [],
          'blocked_users': [],
          'bookmarkedMenus': [],
          'coupons': [],
          'eatenMenus': [],
          'grade': 0,
          'inCampus': false,
          'status': {
            'text': '',
          },
          'university': '',
          'visitedRestaurants': [],
        });
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (e.code == 'weak-password') {
          _snackBarErrorMessageTemplate('そのパスワードは弱すぎます');
        } else if (e.code == 'email-already-in-use') {
          _snackBarErrorMessageTemplate('そのメールアドレスは既に使われています');
        } else if (e.code == 'invalid-email') {
          _snackBarErrorMessageTemplate('無効なメールアドレスです');
        } else {
          _snackBarErrorMessageTemplate('サインインに失敗しました');
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.lightGreen.shade100,
            Colors.blue.shade700,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: AuthForm(
                _submitAuthForm,
                _isLoading,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

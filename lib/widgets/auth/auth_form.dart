import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../screens/auth/termOfService.dart';

class AuthForm extends StatefulWidget {
  final Function submitFn;
  final bool isLoading;

  AuthForm(this.submitFn, this.isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _userEmail = '';
  String _userPassword = '';

  void _trySubmit({isGuest = false}) {
    if (isGuest) {
      widget.submitFn(
        email: 'guest@guest.com',
        password: 'guestguest',
        isLogin: true,
      );
    } else {
      final bool isValid = _formKey.currentState!.validate();
      FocusScope.of(context).unfocus();

      if (isValid) {
        _formKey.currentState!.save();
        widget.submitFn(
          email: _userEmail.trim(),
          password: _userPassword.trim(),
          isLogin: _isLogin,
        );
      }
    }
  }

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

  Future<void> _sendPasswordResetEmail(String email) async {
    Navigator.of(context).pop();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (e.code == 'invalid-email') {
        _snackBarErrorMessageTemplate('無効なメールアドレスです');
      } else if (e.code == 'user-not-found') {
        _snackBarErrorMessageTemplate('そのメールアドレスは登録されていません');
      } else {
        _snackBarErrorMessageTemplate('メール送信に失敗しました');
      }
    }
  }

  void _resetPassword() {
    final TextEditingController _emailController = TextEditingController();
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              color: Colors.transparent,
              height: 300,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    'パスワード再設定メールを送信',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'メールアドレス',
                    ),
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    enableSuggestions: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  ElevatedButton(
                      onPressed: _emailController.text.trim().isEmpty
                          ? null
                          : () => _sendPasswordResetEmail(
                              _emailController.text.trim()),
                      child: Text('メール送信'),
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).accentColor,
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  key: ValueKey('email'),
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  enableSuggestions: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'メールアドレス',
                  ),
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return '有効なメールアドレスを入力してください';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    _userEmail = value!;
                  },
                ),
                TextFormField(
                  key: ValueKey('password'),
                  decoration: InputDecoration(
                    labelText: 'パスワード',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 7) {
                      return 'パスワードは7文字以上入力してください';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    _userPassword = value!;
                  },
                ),
                if (_isLogin)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: _resetPassword,
                        child: Text(
                          'パスワードを忘れましたか？',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 17,
                ),
                if (!_isLogin)
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(TermOfService.routeName),
                    child: Text('利用規約'),
                  ),
                if (widget.isLoading) CircularProgressIndicator(),
                if (!widget.isLoading)
                  ElevatedButton(
                    onPressed: _trySubmit,
                    child: Text(_isLogin ? 'ログイン' : '利用規約に同意してサインアップ'),
                    style: ElevatedButton.styleFrom(
                      primary: _isLogin
                          ? Theme.of(context).accentColor
                          : Colors.pink,
                    ),
                  ),
                if (!widget.isLoading)
                  TextButton(
                    onPressed: () => setState(() {
                      _isLogin = !_isLogin;
                    }),
                    child: Text(
                      _isLogin ? '新しいアカウントを作る' : 'アカウントを持っている',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                // TextButton(
                //   onPressed: () => _trySubmit(isGuest: true),
                //   child: Text('ゲストとしてログインする'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

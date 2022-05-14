import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../widgets/account/user_image_picker.dart';
import '../../configs/general.dart';

class AccountInfoEditScreen extends StatefulWidget {
  static const routeName = '/account-info-edit';

  @override
  _AccountInfoEditScreenState createState() => _AccountInfoEditScreenState();
}

class _AccountInfoEditScreenState extends State<AccountInfoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userImageFile = '';
  String _userName = '';
  String _university = '';
  int _grade = 0;
  DateTime _birthday = DateTime.now();
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isInit = true;
  var _isEdit;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _isEdit = ModalRoute.of(context)!.settings.arguments;
      if (_isEdit != null) {
        setState(() {
          _isLoading = true;
        });
        final String userId = FirebaseAuth.instance.currentUser!.uid;
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        _userName = userData['username'];
        _university = userData['university'];
        _grade = userData['grade'];
        if (userData.data()!.containsKey('birthday')) {
          _birthday = userData['birthday'].toDate();
        }
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final File downloadToFile = File('${appDocDir.path}/$userId.jpg');
        await FirebaseStorage.instance
            .ref()
            .child('user_profile_images')
            .child('$userId.jpg')
            .writeToFile(downloadToFile);
        _userImageFile = downloadToFile.path;
        setState(() {
          _isLoading = false;
        });
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _pickImage(String image) {
    _userImageFile = image;
  }

  void _saveAccountInfo() async {
    final bool isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'プロフィール写真を選んでください',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    } else if (_university.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '大学を選んでください',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    } else if (_grade == 0) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '学年を選んでください',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }
    // else if (_birthday.year == DateTime.now().year &&
    //     _birthday.month == DateTime.now().month &&
    //     _birthday.day == DateTime.now().day) {
    //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text(
    //         '生年月日を選択してください',
    //         textAlign: TextAlign.center,
    //       ),
    //     ),
    //   );
    //   return;
    // }

    if (isValid) {
      setState(() {
        _isSaving = true;
      });
      _formKey.currentState!.save();
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      final Reference imageRef = FirebaseStorage.instance
          .ref()
          .child('user_profile_images')
          .child('$userId.jpg');
      await imageRef.putFile(File(_userImageFile));
      final String imageUrl = await imageRef.getDownloadURL();

      Map<String, Object> updatedDatas = {
        'image_url': imageUrl,
        'username': _userName.trim(),
        'university': _university,
        'grade': _grade,
      };
      if (!(_birthday.year == DateTime.now().year &&
          _birthday.month == DateTime.now().month &&
          _birthday.day == DateTime.now().day)) {
        updatedDatas['birthday'] = Timestamp.fromDate(_birthday);
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updatedDatas);
      if (_isEdit != null) {
        Navigator.of(context).pop();
      }
    }
  }

  void _select(List items, Function func) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: 50,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items
                .map((item) => SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          func(item);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          item,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'アカウント情報編集',
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontSize: 25,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 70,
                      horizontal: 50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        UserImagePicker(
                          _userImageFile,
                          _pickImage,
                        ),
                        TextFormField(
                          initialValue: _userName,
                          decoration: InputDecoration(
                            labelText: '名前',
                          ),
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.done,
                          maxLength: 10,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '名前を入力してください';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            _userName = value!;
                          },
                        ),
                        OutlinedButton(
                          child: Text(
                            _university.isEmpty ? '大学' : _university,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black,
                          ),
                          onPressed: () => _select(
                            universities,
                            (item) => setState(() {
                              _university = item;
                            }),
                          ),
                        ),
                        OutlinedButton(
                          child: Text(
                            _grade == 0 ? '学年' : '$_grade',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black,
                          ),
                          onPressed: () => _select(
                            grades,
                            (item) => setState(() {
                              _grade = int.parse(item);
                            }),
                          ),
                        ),
                        OutlinedButton(
                          child: Text(
                            _birthday.year == DateTime.now().year &&
                                    _birthday.month == DateTime.now().month &&
                                    _birthday.day == DateTime.now().day
                                ? '生年月日（任意）'
                                : "${DateFormat('yyyy/MM/dd').format(_birthday)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            primary: Colors.black,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return SizedBox(
                                  height: 300,
                                  child: CupertinoDatePicker(
                                    minimumYear: DateTime.now().year - 100,
                                    maximumYear: DateTime.now().year,
                                    initialDateTime: _birthday,
                                    mode: CupertinoDatePickerMode.date,
                                    onDateTimeChanged: (dateTime) =>
                                        setState(() {
                                      this._birthday = dateTime;
                                    }),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 70,
                            vertical: 40,
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).accentColor,
                              elevation: 10,
                              shape: const StadiumBorder(),
                            ),
                            onPressed: _saveAccountInfo,
                            child: _isSaving
                                ? CircularProgressIndicator()
                                : Text('保存'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

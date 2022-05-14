import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final String initialImage;
  final Function imagePickFunc;

  UserImagePicker(this.initialImage, this.imagePickFunc);

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  String _pickedImage = '';

  @override
  void initState() {
    super.initState();
    _pickedImage = widget.initialImage;
  }

  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) {
      return;
    }
    setState(() {
      _pickedImage = image.path;
    });
    widget.imagePickFunc(_pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage('dev_assets/veroo.png'),
          foregroundImage: _pickedImage != ''
              ? FileImage(File(_pickedImage))
              : AssetImage('dev_assets/veroo.png') as ImageProvider,
        ),
        FlatButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text('プロフィール写真を選択'),
          textColor: Theme.of(context).accentColor,
        ),
      ],
    );
  }
}

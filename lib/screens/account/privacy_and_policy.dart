import 'package:flutter/material.dart';

import '../../configs/general.dart';

class PrivacyAndPolicy extends StatelessWidget {
  static const routeName = '/privacy-and-policy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Text(privacyAndPolicy),
      ),
    );
  }
}

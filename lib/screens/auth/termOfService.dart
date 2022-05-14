import 'package:flutter/material.dart';

import '../../configs/general.dart';

class TermOfService extends StatelessWidget {
  static const routeName = '/term-of-service';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Text(termOfService),
      ),
    );
  }
}

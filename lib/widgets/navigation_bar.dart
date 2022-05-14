import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import '../screens/home/home_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/account/account_screen.dart';

class NavigationBar extends StatefulWidget {
  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  // final bool _isGuest =
  //     FirebaseAuth.instance.currentUser!.uid == 'Mucj7882asg7YQrvaXp4jqDbT5m1';
  int _selectedPageIndex = 0;
  static List<Widget> _pages = [
    HomeScreen(),
    ChatScreen(),
    AccountScreen(),
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).primaryColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.yellow,
        currentIndex: _selectedPageIndex,
        onTap: _selectPage,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'ホーム',
          ),
          // if (!_isGuest)
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
            ),
            label: 'チャット',
          ),
          // if (!_isGuest)
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
            ),
            label: 'アカウント',
          ),
        ],
      ),
    );
  }
}

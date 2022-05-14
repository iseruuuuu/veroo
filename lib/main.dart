import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/restaurant/restaurant_detail_screen.dart';
import 'screens/search/advanced_search_screen.dart';
import 'screens/search/search_results_screen.dart';
import 'screens/search/search_results_detail_screen.dart';
import 'screens/account/account_screen.dart';
import 'screens/account/account_info_edit_screen.dart';
import 'screens/account/follow_and_follower_screen.dart';
import 'screens/account/privacy_and_policy.dart';
import 'screens/auth/termOfService.dart';
import 'screens/chat/chat_detail_screen.dart';
import 'screens/home/status_screen.dart';
import 'screens/coupon/coupon_screen.dart';
import 'widgets/navigation_bar.dart';
import 'providers/restaurants.dart';
import 'providers/content_lists.dart';
import 'providers/posts.dart';
import 'providers/friends.dart';
import 'models/user.dart' as user;

void main() => runApp(MyApp());

class Splash extends StatefulWidget {
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(
      Duration(milliseconds: 1500),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 244, 34, 1),
      body: Center(
        child: Image.asset(
          'dev_assets/veroo.png',
          width: 167,
          height: 167,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Restaurants()),
        ChangeNotifierProvider.value(value: ContentLists()),
        ChangeNotifierProvider.value(value: Posts()),
        ChangeNotifierProvider.value(value: Friends()),
      ],
      child: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (BuildContext context, AsyncSnapshot snapshot) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Veroo',
          theme: ThemeData(
            primaryColor: Colors.black,
            accentColor: Colors.cyan.shade300,
            scaffoldBackgroundColor: Colors.white,
          ),
          home: Splash(),
          routes: {
            AccountInfoEditScreen.routeName: (BuildContext context) =>
                AccountInfoEditScreen(),
            RestaurantDetailScreen.routeName: (BuildContext context) =>
                RestaurantDetailScreen(),
            AccountScreen.routeName: (BuildContext context) => AccountScreen(),
            AdvancedSearchScreen.routeName: (BuildContext context) =>
                AdvancedSearchScreen(),
            FollowAndFollowerScreen.routeName: (BuildContext context) =>
                FollowAndFollowerScreen(),
            ChatDetailScreen.routeName: (BuildContext context) =>
                ChatDetailScreen(),
            SearchResultsScreen.routeName: (BuildContext context) =>
                SearchResultsScreen(),
            SearchResultsDetailScreen.routeName: (BuildContext context) =>
                SearchResultsDetailScreen(),
            CouponScreen.routeName: (BuildContext context) => CouponScreen(),
            StatusScreen.routeName: (BuildContext context) => StatusScreen(),
            PrivacyAndPolicy.routeName: (BuildContext context) =>
                PrivacyAndPolicy(),
            TermOfService.routeName: (BuildContext context) => TermOfService(),
          },
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        } else if (snapshot.hasData) {
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data.uid)
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (userSnapshot.data['username'] == '' ||
                  userSnapshot.data['image_url'] == '' ||
                  userSnapshot.data['university'] == '' ||
                  userSnapshot.data['grade'] == 0) {
                return AccountInfoEditScreen();
              } else {
                user.User(uid: snapshot.data.uid, name: '', imageUrl: '')
                    .trackCurrentPosition(userSnapshot.data['university']);
                return NavigationBar();
              }
            },
          );
        } else {
          return AuthScreen();
        }
      },
    );
  }
}

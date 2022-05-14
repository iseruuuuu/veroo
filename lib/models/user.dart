import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../configs/university_coords.dart';

class User {
  final String uid;
  final String name;
  final String imageUrl;

  User({
    required this.uid,
    required this.name,
    required this.imageUrl,
  });

  Future<bool> _checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Future.error('位置情報サービスは無効になっています');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Future.error('位置情報の権限が拒否されました');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Future.error('位置情報のアクセス許可は完全に拒否されます。アクセス許可をリクエストすることはできません。');
      return false;
    }

    return true;
  }

  bool _isInCampus(double latitude, double longitude, String university) {
    if (university == '明治大学(和泉)') {
      return (MeijiIzumi.latitudes[0] <= latitude &&
              latitude <= MeijiIzumi.latitudes[1]) &&
          (MeijiIzumi.longitudes[0] <= longitude &&
              longitude <= MeijiIzumi.longitudes[1]);
    } else if (university == '明治大学(駿河台)') {
      return (MeijiSurugadai.latitudes[0] <= latitude &&
              latitude <= MeijiSurugadai.latitudes[1]) &&
          (MeijiSurugadai.longitudes[0] <= longitude &&
              longitude <= MeijiSurugadai.longitudes[1]);
    } else {
      return false;
    }
  }

  void trackCurrentPosition(String university) async {
    final flag = await _checkPermission();
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    bool wasInCampus = userData.data()!['inCampus'];

    if (flag) {
      final LocationSettings locationSettings =
          LocationSettings(accuracy: LocationAccuracy.high);
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position? position) async {
        if (position != null) {
          final bool isInCampus =
              _isInCampus(position.latitude, position.longitude, university);
          if (isInCampus != wasInCampus) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .update({'inCampus': isInCampus});
            wasInCampus = isInCampus;
          }
        }
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:url_launcher/url_launcher.dart";

import '../../widgets/restaurant/is_visited_button.dart';
import '../../widgets/restaurant/map_utils.dart';
import '../../widgets/restaurant/menu_list.dart';
import '../../widgets/restaurant/image_scroll_container.dart';

class RestaurantDetailScreen extends StatelessWidget {
  static const routeName = '/restaurant-detail';

  Widget _listTile(String key, String value) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(
            key,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _propertyBlock(IconData icon, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Icon(icon),
          ),
          Expanded(
            flex: 4,
            child: content,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurantId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('restaurants')
            .doc(restaurantId)
            .get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasData) {
              List<String> _images = [];
              snapshot.data['images'].forEach((url) => _images.add(url));
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Stack(
                      alignment: AlignmentDirectional.topEnd,
                      children: <Widget>[
                        ImageScrollContainer(_images),
                        IsVisitedButton(restaurantId),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      width: double.infinity,
                      child: Text(
                        snapshot.data['name'],
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _propertyBlock(
                      Icons.map,
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              snapshot.data['location'],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              child: const Text(
                                'Mapへ',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey[300],
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () => MapUtils.openMap(
                                snapshot.data['coords'].latitude,
                                snapshot.data['coords'].longitude,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _propertyBlock(
                      Icons.watch_later,
                      Column(
                        children: <Widget>[
                          _listTile('ランチ', snapshot.data['time']['lunch']),
                          _listTile('カフェ', snapshot.data['time']['cafe']),
                          _listTile('ディナー', snapshot.data['time']['dinner']),
                          _listTile('定休日', snapshot.data['time']['close']),
                          _listTile('備考', snapshot.data['time']['other']),
                        ],
                      ),
                    ),
                    _propertyBlock(
                      Icons.payment,
                      Text(
                        snapshot.data['payment'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _propertyBlock(
                      Icons.school,
                      Column(
                        children: <Widget>[
                          _listTile(
                            '明大前',
                            "${snapshot.data['fromCampus']['明大前']}分",
                          ),
                          _listTile(
                            '御茶ノ水',
                            "${snapshot.data['fromCampus']['御茶ノ水']}分",
                          ),
                        ],
                      ),
                    ),
                    _propertyBlock(
                      Icons.phone,
                      GestureDetector(
                        onTap: () async {
                          final String tel = "tel:${snapshot.data['phone']}";
                          if (await canLaunch(tel)) {
                            await launch(tel);
                          } else {
                            final Error error =
                                ArgumentError('$telに電話をかけることができません');
                            throw error;
                          }
                        },
                        child: Text(
                          snapshot.data['phone'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ),
                    _propertyBlock(
                      snapshot.data['smoke']
                          ? Icons.smoking_rooms_rounded
                          : Icons.smoke_free,
                      Text(
                        snapshot.data['smoke'] ? '喫煙可' : '喫煙不可',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    MenuList(
                      snapshot.data['menus'],
                      snapshot.data['takeoutMenus'],
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text(
                  'データが存在しません',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.grey,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

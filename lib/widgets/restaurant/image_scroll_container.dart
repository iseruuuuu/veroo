import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageScrollContainer extends StatelessWidget {
  List<dynamic> images;

  ImageScrollContainer(this.images);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: CarouselSlider(
        items: images
            .map(
              (url) => PinchZoomImage(
                image: SizedBox(
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/post_images_placeholder.png',
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, error) =>
                        Center(child: Icon(Icons.error)),
                  ),
                ),
              ),
            )
            .toList(),
        options: CarouselOptions(
          viewportFraction: 1,
          initialPage: 0,
          aspectRatio: 1,
        ),
      ),
    );
  }
}

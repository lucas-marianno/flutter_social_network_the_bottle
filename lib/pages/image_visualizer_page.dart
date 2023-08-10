import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageVisualizer extends StatelessWidget {
  const ImageVisualizer(this.imageUrl, {super.key});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: 'profilePic',
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}

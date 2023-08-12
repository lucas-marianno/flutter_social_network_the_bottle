import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageVisualizer extends StatelessWidget {
  const ImageVisualizer({
    super.key,
    this.imageUrl,
    this.image,
  });
  final String? imageUrl;
  final Uint8List? image;

  @override
  Widget build(BuildContext context) {
    assert((imageUrl != null) ^ (image != null));

    if (imageUrl != null) {
      return Scaffold(
        body: Hero(
          tag: 'profilePic',
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl!),
          ),
        ),
      );
    }
    return Scaffold(
      body: Hero(
        tag: 'profilePic',
        child: PhotoView(
          imageProvider: MemoryImage(image!),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../pages/image_visualizer_page.dart';

class PostPicture extends StatelessWidget {
  const PostPicture({
    super.key,
    required this.context,
    required this.postImageUrl,
    this.padding,
    this.imageHeight = 300,
    this.onTap,
  });
  final BuildContext context;
  final String? postImageUrl;
  final EdgeInsetsGeometry? padding;
  final void Function()? onTap;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    if (postImageUrl == null) return const SizedBox(width: 0, height: 0);
    try {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: GestureDetector(
          onTap: onTap ??
              () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageVisualizerPage(imageUrl: postImageUrl),
                    ),
                  ),
          child: CachedNetworkImage(
            imageUrl: postImageUrl!,
            height: imageHeight,
            width: imageHeight,
            memCacheHeight: imageHeight.toInt(),
            fit: BoxFit.cover,
          ),
        ),
      );
    } catch (e) {
      return SizedBox(
        height: imageHeight,
        child: Column(
          children: [
            const Text('There was a problem fetching the image!'),
            const Text(''),
            Text(e.toString()),
          ],
        ),
      );
    }
  }
}

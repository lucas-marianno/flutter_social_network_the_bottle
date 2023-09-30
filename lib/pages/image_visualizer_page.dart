import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:the_bottle/components/dialog/show_snackbar.dart';
import 'package:the_bottle/components/list_tile.dart';
import 'package:the_bottle/components/dialog/options_modal_bottom_sheet.dart';
import 'package:the_bottle/util/temporary_save_network_image.dart';

class ImageVisualizerPage extends StatelessWidget {
  const ImageVisualizerPage({
    super.key,
    this.imageUrl,
    this.image,
  });
  final String? imageUrl;
  final Uint8List? image;

  @override
  Widget build(BuildContext context) {
    assert(
      (imageUrl != null) ^ (image != null),
      'Only one image source should be provided.',
    );

    if (imageUrl != null) {
      return Scaffold(
        body: Hero(
          tag: 'profilePic',
          child: GestureDetector(
            onLongPress: () {
              optionsFromModalBottomSheet(context, children: [
                MyListTile(
                  iconData: Icons.download,
                  text: 'Download Image',
                  onTap: () async {
                    Navigator.of(context).pop();
                    try {
                      final path = await saveTemporaryNetworkImage(imageUrl!);
                      final result = await GallerySaver.saveImage(path!, albumName: 'The Bottle');
                      // ignore: use_build_context_synchronously
                      showMySnackBar(
                        context,
                        result == true ? 'Image saved to gallery' : 'Image could not be saved',
                      );
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      showMySnackBar(context, 'There was a problem: $e');
                    }
                  },
                )
              ]);
            },
            child: PhotoView(
              minScale: PhotoViewComputedScale.contained * 0.5,
              maxScale: PhotoViewComputedScale.contained * 10,
              imageProvider: CachedNetworkImageProvider(imageUrl!),
            ),
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

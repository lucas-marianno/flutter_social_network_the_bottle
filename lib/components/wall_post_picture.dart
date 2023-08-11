import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostPicture extends StatelessWidget {
  const PostPicture({
    super.key,
    required this.postId,
  });
  final String? postId;

  @override
  Widget build(BuildContext context) {
    if (postId == null) return Container();
    return Flexible(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('User Posts').doc(postId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            final String? postPictureUrl = snapshot.data!.data()!['postPictureUrl'];
            if (postPictureUrl != null) {
              return CachedNetworkImage(
                imageUrl: postPictureUrl,
                memCacheHeight: 50,
                memCacheWidth: 50,
              );
            }
            // TODO: uncomment this after a post with picture
            // else {
            //   return Container();
            // }
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 300,
            width: 300,
            child: Icon(
              Icons.image,
              size: 100,
              color: Theme.of(context).colorScheme.surface,
            ),
          );
        },
      ),
    );
  }
}

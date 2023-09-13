import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ProfilePictureSize { small, medium, large }

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({
    super.key,
    required this.profileEmailId,
    this.size = ProfilePictureSize.small,
    this.onTap,
  });
  final String profileEmailId;
  final ProfilePictureSize size;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    late double imgSize;
    switch (size) {
      case ProfilePictureSize.small:
        imgSize = 40;
        break;
      case ProfilePictureSize.medium:
        imgSize = 120;
        break;
      case ProfilePictureSize.large:
        imgSize = 250;
        break;
    }

    return Container(
      height: imgSize,
      width: imgSize,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('User Profile')
                .doc(profileEmailId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.connectionState.name == 'active') {
                final imgUrl = snapshot.data!.data()?['pictureUrl'];
                if (imgUrl != null) {
                  return ConstrainedBox(
                    constraints: BoxConstraints.loose(Size.square(imgSize)),
                    child: CachedNetworkImage(
                      imageUrl: imgUrl,
                      fit: BoxFit.cover,
                      width: imgSize,
                      memCacheWidth: 200,
                      useOldImageOnUrlChange: true,
                    ),
                  );
                }
                return Image.asset('lib/assets/avatar.jpg', fit: BoxFit.cover);
              } else {
                return Center(
                  child: LinearProgressIndicator(
                    minHeight: imgSize,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

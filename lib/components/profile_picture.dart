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
  final String? profileEmailId;
  final ProfilePictureSize size;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    late double imgSize;
    late double imgScale;
    late double iconSize;
    late Color iconColor;
    switch (size) {
      case ProfilePictureSize.small:
        imgSize = 40;
        iconSize = 40;
        imgScale = 0.01;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
      case ProfilePictureSize.medium:
        imgSize = 120;
        iconSize = 75;
        imgScale = 0.1;
        iconColor = Theme.of(context).colorScheme.onPrimary;
        break;
      case ProfilePictureSize.large:
        imgSize = 250;
        iconSize = 150;
        imgScale = 1;
        iconColor = Theme.of(context).colorScheme.primary;
        break;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: imgSize,
        width: imgSize,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('User Profile').doc(profileEmailId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.connectionState.name == 'active') {
              final imgUrl = snapshot.data!.data()?['pictureUrl'];
              final thumbUrl = snapshot.data!.data()?['thumbnailUrl'];
              final thumbnail = thumbUrl != null
                  ? Image.network(thumbUrl, fit: BoxFit.cover)
                  : LinearProgressIndicator(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      color: Theme.of(context).colorScheme.surface,
                      minHeight: imgSize,
                    );
              if (imgUrl != null) {
                return Image.network(
                  imgUrl,
                  scale: imgScale,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return thumbnail;
                  },
                );
              }
              return Icon(
                Icons.person,
                size: iconSize,
                color: iconColor,
              );
            } else {
              return Center(
                child: LinearProgressIndicator(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  color: Theme.of(context).colorScheme.surface,
                  minHeight: imgSize,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

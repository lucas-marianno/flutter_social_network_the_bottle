import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    required this.nOfLikes,
  });

  final bool isLiked;
  final int nOfLikes;
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_outline,
            color: isLiked ? Colors.red : Colors.grey,
          ),
        ),
        Text('$nOfLikes')
      ],
    );
  }
}

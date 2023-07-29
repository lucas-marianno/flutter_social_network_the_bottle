import 'package:flutter/material.dart';

class CommentButton extends StatelessWidget {
  const CommentButton({
    super.key,
    required this.onTap,
    required this.nOfComments,
  });

  final void Function()? onTap;
  final int nOfComments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
            onTap: onTap, child: const Icon(Icons.comment_outlined, color: Colors.grey)),
        Text('$nOfComments')
      ],
    );
  }
}

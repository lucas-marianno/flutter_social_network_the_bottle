import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BlurredAppBar({
    super.key,
    this.title,
    this.centerTitle,
    this.actions,
  });

  final Widget? title;
  final List<Widget>? actions;
  final bool? centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 15),
        child: AppBar(
          centerTitle: centerTitle,
          title: title,
          actions: actions,
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BlurredAppBar({
    super.key,
    this.title,
    this.centerTitle,
    this.actions,
    this.onTap,
  });

  final Widget? title;
  final List<Widget>? actions;
  final bool? centerTitle;
  final void Function()? onTap;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 15),
        child: GestureDetector(
          onTap: onTap,
          child: AppBar(
            centerTitle: centerTitle,
            title: title,
            actions: actions,
          ),
        ),
      ),
    );
  }
}

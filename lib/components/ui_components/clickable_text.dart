import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher_string.dart';

class ClickableText extends StatelessWidget {
  const ClickableText(
    this.text, {
    super.key,
    this.style,
  });
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Linkify(
      text: text,
      textAlign: TextAlign.justify,
      style: style,
      linkStyle: const TextStyle(decoration: TextDecoration.none),
      onOpen: (link) {
        url_launcher.launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication);
      },
    );
  }
}

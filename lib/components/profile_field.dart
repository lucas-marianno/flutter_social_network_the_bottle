import 'package:flutter/material.dart';
import 'package:the_bottle/components/clickable_text.dart';

class ProfileField extends StatelessWidget {
  const ProfileField({
    super.key,
    required this.sectionName,
    required this.text,
    required this.onTap,
    this.editable = false,
  });
  final String sectionName;
  final String text;
  final Function()? onTap;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: editable ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // field name + settings icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sectionName,
                  style: const TextStyle(fontSize: 18),
                ),
                !editable
                    ? Container()
                    : IconButton(
                        onPressed: onTap,
                        icon: const Icon(
                          Icons.edit,
                        ),
                      ),
              ],
            ),
            // field value
            ClickableText(
              text,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

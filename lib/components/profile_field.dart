import 'package:flutter/material.dart';

class ProfileField extends StatelessWidget {
  const ProfileField({
    super.key,
    required this.sectionName,
    required this.text,
    required this.onTap,
  });
  final String sectionName;
  final String text;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // height: 100,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
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
                  style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 18),
                ),
                IconButton(
                  onPressed: onTap,
                  icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onBackground),
                )
              ],
            ),
            const SizedBox(height: 10),

            // field value
            Text(
              text,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

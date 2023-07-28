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
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white),
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 18),
                ),
                IconButton(onPressed: onTap, icon: Icon(Icons.edit, color: Colors.grey[600]))
              ],
            ),
            const SizedBox(height: 10),

            // field value
            Text(
              text,
              style: TextStyle(color: Colors.grey[900], fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

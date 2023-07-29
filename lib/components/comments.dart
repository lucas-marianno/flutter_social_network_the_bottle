import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  const Comment({
    super.key,
    required this.text,
    required this.user,
    required this.time,
  });
  final String text;
  final String user;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // comment
          Text(text),
          // user ・ time
          Row(
            children: [
              Text(user),
              const Text(' ● '),
              Text(time),
            ],
          )
        ],
      ),
    );
  }
}

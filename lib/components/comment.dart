import 'package:flutter/material.dart';
import 'package:the_wall/components/username.dart';

class Comment extends StatelessWidget {
  const Comment({
    super.key,
    required this.text,
    required this.user,
    required this.timestamp,
  });
  final String text;
  final String user;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            // TODO: implement comment likes:
            // wrap this in a row, and add an like button by the end
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // user + time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // user
                  Username(postOwner: user),
                  // timestamp
                  Text(
                    timestamp,
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // comment
              Text(text, textAlign: TextAlign.justify),
            ],
          ),
        ),
        const Icon(Icons.favorite_outline),
      ],
    );
  }
}

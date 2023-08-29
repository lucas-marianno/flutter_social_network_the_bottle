import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Username extends StatelessWidget {
  const Username({
    super.key,
    required this.userEmail,
    this.style,
    this.onTap,
  });
  final String userEmail;
  final void Function()? onTap;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size(MediaQuery.of(context).size.width - 200, 50)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('User Profile').doc(userEmail).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.data() != null) {
                return Text(
                  snapshot.data!.data()!['username'] ?? userEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              } else if (snapshot.data?.data() == null) {
                return Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              } else {
                return const Expanded(
                  child: LinearProgressIndicator(
                    minHeight: 16,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

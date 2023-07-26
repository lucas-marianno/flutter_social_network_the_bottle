import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'list_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const DrawerHeader(
              child: Icon(
                Icons.person,
                size: 75,
                color: Colors.grey,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  MyListTile(iconData: Icons.home, text: 'H O M E', onTap: () {}),
                  MyListTile(
                    iconData: Icons.person,
                    text: 'P R O F I L E',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const Divider(
              height: 32,
            ),
            MyListTile(
              iconData: Icons.logout,
              text: 'L O G O U T',
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

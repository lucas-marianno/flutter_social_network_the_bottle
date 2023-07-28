import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/pages/home_page.dart';
import 'package:the_wall/pages/profile_page.dart';

import 'list_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    void goToPage(Widget page) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => page,
        ),
      );
    }

    void logout() async {
      await FirebaseAuth.instance.signOut();
    }

    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const DrawerHeader(
                  child: Icon(Icons.person, size: 75, color: Colors.grey),
                ),
                MyListTile(
                  iconData: Icons.home,
                  text: 'H O M E',
                  onTap: () => goToPage(const HomePage()),
                ),
                MyListTile(
                  iconData: Icons.person,
                  text: 'P R O F I L E',
                  onTap: () => goToPage(const ProfilePage()),
                ),
              ],
            ),
            const Divider(height: 32),
            MyListTile(
              iconData: Icons.logout,
              text: 'L O G O U T',
              onTap: logout,
            ),
          ],
        ),
      ),
    );
  }
}

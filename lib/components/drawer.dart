import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/profile_picture.dart';
import 'package:the_wall/pages/profile_page.dart';
import '../pages/setting_page.dart';
import 'list_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    void goToPage(Widget page) {
      // Navigator.of(context).pop();
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
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  DrawerHeader(
                    child: Hero(
                      tag: 'profilePic',
                      child: ProfilePicture(
                        profileEmailId: FirebaseAuth.instance.currentUser!.email,
                        size: ProfilePictureSize.medium,
                        onTap: () => goToPage(const ProfilePage()),
                      ),
                    ),
                  ),
                  MyListTile(
                    iconData: Icons.home,
                    text: 'H O M E',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  MyListTile(
                    iconData: Icons.person,
                    text: 'P R O F I L E',
                    onTap: () => goToPage(const ProfilePage()),
                  ),
                  MyListTile(
                    iconData: Icons.settings,
                    text: 'S E T T I N G S',
                    onTap: () => goToPage(const SettingsPage()),
                  ),
                ],
              ),
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

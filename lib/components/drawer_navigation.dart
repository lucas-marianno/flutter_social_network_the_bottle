import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/profile_picture.dart';
import 'package:the_bottle/pages/about_page.dart';
import 'package:the_bottle/pages/profile_page.dart';
import '../pages/settings_page.dart';
import 'list_tile.dart';

class DrawerNavigation extends StatelessWidget {
  const DrawerNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

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
                        profileEmailId: currentUser!.email!,
                        size: ProfilePictureSize.medium,
                        onTap: () => goToPage(
                          ProfilePage(
                            userEmail: currentUser.email!,
                            heroTag: 'profilePic',
                          ),
                        ),
                      ),
                    ),
                  ),
                  MyListTile(
                    iconData: Icons.home,
                    text: 'H O M E',
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  MyListTile(
                    iconData: Icons.person,
                    text: 'P R O F I L E',
                    onTap: () => goToPage(ProfilePage(userEmail: currentUser.email!)),
                  ),
                  MyListTile(
                    iconData: Icons.settings,
                    text: 'S E T T I N G S',
                    onTap: () => goToPage(const SettingsPage()),
                  ),
                  MyListTile(
                    iconData: Icons.info,
                    text: 'A B O U T',
                    onTap: () => goToPage(const AboutPage()),
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

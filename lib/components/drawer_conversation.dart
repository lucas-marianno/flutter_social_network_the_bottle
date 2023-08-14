import 'package:flutter/material.dart';
import 'package:the_wall/components/textfield.dart';

import 'list_tile.dart';

class DrawerConversations extends StatelessWidget {
  const DrawerConversations({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement this!

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(child: Text('C O N V E R S A T I O N S')),
                  MyTextField(
                    hintText: 'Search for a conversation',
                    autofocus: false,
                  ),
                ],
              ),
            ),
            MyListTile(
              iconData: Icons.person,
              text: 'Fulano Silva',
              onTap: () {},
            ),
            MyListTile(
              iconData: Icons.person,
              text: 'Fulano Silva',
              onTap: () {},
            ),
            MyListTile(
              iconData: Icons.person,
              text: 'Fulano Silva',
              onTap: () {},
            ),
            MyListTile(
              iconData: Icons.person,
              text: 'Fulano Silva',
              onTap: () {},
            ),
            MyListTile(
              iconData: Icons.person,
              text: 'Fulano Silva',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

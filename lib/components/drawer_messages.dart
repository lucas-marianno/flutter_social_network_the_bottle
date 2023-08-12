import 'package:flutter/material.dart';
import 'package:the_wall/components/textfield.dart';

import 'list_tile.dart';

class DrawerMessages extends StatelessWidget {
  const DrawerMessages({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement this!

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const DrawerHeader(child: Center(child: Text('C O N V E R S A T I O N S'))),
            const MyTextField(
              hintText: 'Search for a conversation',
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

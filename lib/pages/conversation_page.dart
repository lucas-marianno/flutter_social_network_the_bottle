import 'package:flutter/material.dart';
import 'package:the_wall/components/drawer_conversation.dart';
import '../components/message_baloon.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      // drawer: const MyDrawer(),
      endDrawer: const DrawerConversations(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        title: const Text('FULANO DA SILVA'),
        actions: [
          IconButton(
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
            },
            icon: const Icon(Icons.message),
          )
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: 20,
        itemBuilder: (context, index) {
          return MessageBaloon(
            text: 'message bla ${'bla ' * (index * 2)}',
            timestamp: '12:34',
            sender: 'sender',
            isIncoming: index % 2 == 0,
          );
        },
      ),
    );
  }
}

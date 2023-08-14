import 'package:flutter/material.dart';
import 'package:the_wall/components/drawer.dart';
import 'package:the_wall/components/drawer_conversation.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: const MyDrawer(),
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
              //TODO: go to messages
              //TODO: show messages list in a drawer
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
            text: 'message bla ${'bla' * (index % 10)}',
            timestamp: '12:34',
            sender: 'sender',
          );
        },
      ),
    );
  }
}

class MessageBaloon extends StatelessWidget {
  const MessageBaloon({
    super.key,
    required this.text,
    required this.timestamp,
    required this.sender,
  });

  final String text;
  final String timestamp;
  final String sender;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        color: Colors.grey[800],
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
          bottom: 20,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(sender),
                Text(text),
              ],
            ),
            Positioned(
              right: 0,
              bottom: -20,
              child: Text(timestamp),
            ),
          ],
        ),
      ),
    );
  }
}

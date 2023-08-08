import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/textfield.dart';
import 'package:the_wall/components/wall_post.dart';
import '../components/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  final User user = FirebaseAuth.instance.currentUser!;

  void postMessage() async {
    if (controller.text.isEmpty) return;
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 1500), curve: Curves.decelerate);

    await FirebaseFirestore.instance.collection('User Posts').add({
      'UserEmail': user.email,
      'Message': controller.text,
      'TimeStamp': Timestamp.now(),
      'Likes': []
    });
    controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: const MyDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        title: const Text('T H E  W A L L'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // the wall
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('User Posts')
                    .orderBy('TimeStamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        final isEdited = post.data().containsKey('Edited') ? post['Edited'] : false;
                        return WallPost(
                          message: post['Message'],
                          postOwner: post['UserEmail'],
                          postId: post.id,
                          postTimeStamp: post['TimeStamp'],
                          isEdited: isEdited,
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error ${snapshot.error}'),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).colorScheme.surface,
            height: 32,
          ),

          // post message
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 10),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: controller,
                    hintText: 'Write your post',
                    onSubmited: postMessage,
                    autofocus: false,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    postMessage();
                  },
                  icon: const Icon(Icons.post_add, size: 40),
                )
              ],
            ),
          ),

          // logged in as
          Text('Logged in as ${user.email}', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/drawer_conversation.dart';
import 'package:the_wall/components/input_field.dart';
import 'package:the_wall/components/wall_post.dart';
import 'package:the_wall/components/wall_post_header.dart';
import 'package:the_wall/components/wall_post_picture.dart';
import 'package:the_wall/pages/image_visualizer_page.dart';
import '../components/drawer_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController scrollController = ScrollController();
  final User user = FirebaseAuth.instance.currentUser!;

  void postMessage(String text, Uint8List? loadedImage) async {
    if (text.isEmpty && loadedImage == null) return;
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 1500), curve: Curves.decelerate);

    final post = await FirebaseFirestore.instance
        .collection('User Posts')
        .add({'UserEmail': user.email, 'Message': text, 'TimeStamp': Timestamp.now(), 'Likes': []});

    setState(() {});

    if (loadedImage == null) return;

    addImageToPost(post.id, loadedImage);
  }

  void addImageToPost(String postId, Uint8List image) async {
    // upload picture to firebase storage and retrieve download URL
    final String storageUrl =
        await (await FirebaseStorage.instance.ref('Post Pictures/$postId').putData(image))
            .ref
            .getDownloadURL();

    // upload pictureUrl to firebase database
    FirebaseFirestore.instance.collection('User Posts').doc(postId).set(
      {'Post Picture': storageUrl},
      SetOptions(merge: true),
    );

    // unload image after post
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: const DrawerNavigation(),
      endDrawer: const DrawerConversations(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        title: const Text('T H E  W A L L'),
        actions: [
          IconButton(
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer();
              //TODO: Feature: show messages list in a drawer
              //TODO: Implement: go to messages
            },
            icon: const Icon(Icons.message),
          )
        ],
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
                        String? postPictureUrl;
                        try {
                          postPictureUrl = post['Post Picture'];
                        } catch (e) {
                          e;
                        }
                        return WallPost(
                          header: WallPostHeader(
                            message: post['Message'],
                            postId: post.id,
                            postOwner: post['UserEmail'],
                            postTimeStamp: post['TimeStamp'],
                            isEdited: isEdited,
                          ),
                          message: post['Message'],
                          postId: post.id,
                          postPicture: PostPicture(
                            postImageUrl: postPictureUrl,
                            onTap: () {
                              if (postPictureUrl == null) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ImageVisualizerPage(imageUrl: postPictureUrl!),
                                ),
                              );
                            },
                          ),
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
          // post message
          InputField(postMessageFunction: postMessage),
        ],
      ),
    );
  }
}

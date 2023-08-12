import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_wall/components/drawer_messages.dart';
import 'package:the_wall/components/textfield.dart';
import 'package:the_wall/components/wall_post.dart';
import 'package:the_wall/components/wall_post_header.dart';
import 'package:the_wall/components/wall_post_picture.dart';
import 'package:the_wall/pages/image_visualizer_page.dart';
import '../components/drawer.dart';
import '../components/list_tile.dart';
import '../components/options_modal_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  final User user = FirebaseAuth.instance.currentUser!;
  Uint8List? loadedImage;

  void addImageToPost(String postId) async {
    if (loadedImage == null) return;

    // upload picture to firebase storage and retrieve download URL
    final String storageUrl =
        await (await FirebaseStorage.instance.ref('Post Pictures/$postId').putData(loadedImage!))
            .ref
            .getDownloadURL();

    // upload pictureUrl to firebase database
    FirebaseFirestore.instance.collection('User Posts').doc(postId).set(
      {'Post Picture': storageUrl},
      SetOptions(merge: true),
    );

    // unload image after post
    loadedImage = null;
    setState(() {});
  }

  void postMessage() async {
    if (controller.text.isEmpty && loadedImage == null) return;
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 1500), curve: Curves.decelerate);

    final post = await FirebaseFirestore.instance.collection('User Posts').add({
      'UserEmail': user.email,
      'Message': controller.text,
      'TimeStamp': Timestamp.now(),
      'Likes': []
    });
    controller.clear();
    setState(() {});

    if (loadedImage == null) return;

    addImageToPost(post.id);
  }

  void selectImage() async {
    // prompt user to select camera or gallery
    final ImageSource? imgSource = await optionsFromModalBottomSheet(context, children: [
      MyListTile(
        iconData: Icons.camera,
        text: 'Open camera',
        onTap: () => Navigator.pop(context, ImageSource.camera),
      ),
      MyListTile(
        iconData: Icons.image_search,
        text: 'From gallery',
        onTap: () => Navigator.pop(context, ImageSource.gallery),
      ),
    ]);

    if (imgSource == null) return;

    // retrieve image from user
    final img = await ImagePicker().pickImage(
      source: imgSource,
      imageQuality: 75,
      maxHeight: 1080,
      maxWidth: 1080,
    );

    if (img == null) return;

    loadedImage = await img.readAsBytes();

    setState(() {});
  }

  void unSelectImage() {
    setState(() => loadedImage = null);
  }

  void viewSelectedImage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageVisualizer(image: loadedImage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: const MyDrawer(),
      endDrawer: const DrawerMessages(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        title: const Text('T H E  W A L L'),
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
                                  builder: (context) => ImageVisualizer(imageUrl: postPictureUrl!),
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
          Divider(
            color: Theme.of(context).colorScheme.surface,
            height: 32,
          ),

          // post message
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 10),
            child: Row(
              children: [
                // preview of loaded image
                if (loadedImage == null)
                  Container()
                else
                  GestureDetector(
                    onTap: viewSelectedImage,
                    onLongPress: unSelectImage,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.memory(loadedImage!, fit: BoxFit.cover),
                    ),
                  ),
                loadedImage == null ? Container() : const SizedBox(width: 10),
                // input textfield
                Expanded(
                  child: MyTextField(
                    controller: controller,
                    hintText: loadedImage == null ? 'Write your post' : 'Write your description',
                    onSubmited: postMessage,
                    autofocus: false,
                  ),
                ),
                // post image button
                IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    selectImage();
                  },
                  icon: const Icon(Icons.add_photo_alternate_outlined, size: 38),
                ),
                // post text button
                IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    postMessage();
                  },
                  icon: const Icon(Icons.post_add, size: 40),
                ),
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

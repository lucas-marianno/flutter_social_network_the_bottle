import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_wall/components/input_from_modal_bottom_sheet.dart';
import 'package:the_wall/components/list_tile.dart';
import 'package:the_wall/components/options_modal_bottom_sheet.dart';
import 'package:the_wall/components/profile_picture.dart';
import 'package:the_wall/pages/image_visualizer_page.dart';
import '../components/profile_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  String username = '';
  String bio = '';

  void viewPicture(String? imageUrl) {
    if (imageUrl == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ImageVisualizer(imageUrl),
    ));
  }

  void pickAndUploadPicture() async {
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
    final XFile? imgFile = await ImagePicker().pickImage(source: imgSource, imageQuality: 50);

    if (imgFile == null) return;

    // set filename as user email
    final String filename = 'Profile Pictures/${user.email}';

    // upload to storage (handle web)
    late final TaskSnapshot uploadTask;
    if (kIsWeb) {
      uploadTask = await FirebaseStorage.instance.ref(filename).putData(
            await imgFile.readAsBytes(),
          );
    } else {
      uploadTask = await FirebaseStorage.instance.ref(filename).putFile(
            File(imgFile.path),
          );
    }
    final String imgStorageUrl = await uploadTask.ref.getDownloadURL();

    // save image download URL to database in UserProfile/picture
    await FirebaseFirestore.instance.collection('User Profile').doc(user.email).set({
      'pictureUrl': imgStorageUrl,
    }, SetOptions(merge: true));
  }

  void editUsername() async {
    final newUsername = await getInputFromModalBottomSheet(
      context,
      title: 'New Username',
      startingString: username,
      hintText: 'Username',
    );
    if (newUsername == null || newUsername == username) return;

    await FirebaseFirestore.instance.collection('User Profile').doc(user.email).set({
      'username': newUsername,
    }, SetOptions(merge: true));
  }

  void editBio() async {
    final newBio = await getInputFromModalBottomSheet(
      context,
      title: 'New bio',
      startingString: bio,
      hintText: 'Your new bio...',
      enterKeyPressSubmits: false,
    );

    if (newBio == null || newBio == bio) return;
    await FirebaseFirestore.instance.collection('User Profile').doc(user.email).set({
      'bio': newBio,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        title: const Text('P R O F I L E'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('User Profile').doc(user.email!).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            final profileData = snapshot.data!.data()!;
            username = profileData['username'];
            bio = profileData['bio'];
            final pictureUrl = profileData['pictureUrl'];

            return Padding(
              padding: const EdgeInsets.all(30),
              child: ListView(
                children: [
                  // profile pic
                  const SizedBox(height: 40),
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // profile pic
                        Hero(
                          tag: 'profilePic',
                          child: ProfilePicture(
                            profileEmailId: user.email,
                            size: ProfilePictureSize.large,
                            onTap: () => viewPicture(pictureUrl),
                          ),
                        ),
                        IconButton(
                          onPressed: pickAndUploadPicture,
                          icon: CircleAvatar(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.grey[900],
                            radius: 25,
                            child: const Icon(Icons.add_a_photo),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // user email
                  Text(
                    user.email!,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 70),
                  // user details
                  Text(
                    'My details',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // username
                  ProfileField(sectionName: 'username', text: username, onTap: editUsername),

                  // bio
                  ProfileField(
                    sectionName: 'bio',
                    text: bio,
                    onTap: editBio,
                  ),

                  // my posts
                  Divider(height: 50, color: Theme.of(context).colorScheme.surface),
                  Text('My posts',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 18,
                      )),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data?.data() == null) {
            return const Center(child: Text('Error: User does not exist'));
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
      ),
    );
  }
}

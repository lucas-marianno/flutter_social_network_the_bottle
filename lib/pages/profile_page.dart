import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_bottle/components/list_tile.dart';
import 'package:the_bottle/components/profile_picture.dart';
import 'package:the_bottle/pages/image_visualizer_page.dart';
import '../components/profile_field.dart';
import '../firebase/account/delete_account.dart';
import '../firebase/account/edit_bio.dart';
import '../firebase/account/edit_username.dart';
import '../firebase/account/upload_profile_picture.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.userEmail,
    this.heroTag,
  });

  final String userEmail;
  final String? heroTag;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User currentUser = FirebaseAuth.instance.currentUser!;
  String username = '';
  String bio = '';

  void viewPicture(String? imageUrl) {
    if (imageUrl == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ImageVisualizerPage(imageUrl: imageUrl),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('P R O F I L E'),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('User Profile').doc(widget.userEmail).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            final profileData = snapshot.data!.data()!;
            username = profileData['username'] ?? widget.userEmail.split('@')[0];
            bio = profileData['bio'] ?? 'Write about yourself here...';
            final pictureUrl = profileData['pictureUrl'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // profile pic
                  const Flexible(child: SizedBox(height: 40)),
                  FractionallySizedBox(
                    widthFactor: 0.5,
                    // heightFactor: 0.2,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // profile pic
                        Hero(
                          tag: widget.heroTag ?? 'null',
                          child: ProfilePicture(
                            profileEmailId: widget.userEmail,
                            size: ProfilePictureSize.large,
                            onTap: () => viewPicture(pictureUrl),
                          ),
                        ),
                        // add image button
                        widget.userEmail != currentUser.email
                            ? Container()
                            : IconButton(
                                onPressed: () =>
                                    pickAndUploadProfilePicture(widget.userEmail, context),
                                icon: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.grey[900],
                                  radius: MediaQuery.of(context).size.width * 0.045,
                                  child: const Icon(Icons.add_a_photo),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const Flexible(child: SizedBox(height: 20)),
                  // user email
                  Text(
                    widget.userEmail,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const Flexible(child: SizedBox(height: 70)),
                  // user details
                  const Text(
                    'My details',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const Flexible(child: SizedBox(height: 20)),
                  // username
                  ProfileField(
                    sectionName: 'username',
                    text: username,
                    onTap: () => editUsername(username, widget.userEmail, context),
                    editable: widget.userEmail == currentUser.email,
                  ),
                  const Flexible(child: SizedBox(height: 15)),
                  // bio
                  ProfileField(
                    sectionName: 'bio',
                    text: bio,
                    onTap: () => editBio(bio, widget.userEmail, context),
                    editable: widget.userEmail == currentUser.email,
                  ),
                  const Spacer(),
                  // delete account
                  widget.userEmail != currentUser.email
                      ? Container()
                      : MyListTile(
                          iconData: Icons.delete,
                          text: 'Delete Acount',
                          onTap: () => deleteAccount(widget.userEmail, context),
                          reverseColors: true,
                        ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data?.data() == null) {
            return const Center(child: Text('Error: User does not exist'));
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

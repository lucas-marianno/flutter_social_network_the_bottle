import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/input_from_modal_bottom_sheet.dart';
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
      'bio': bio,
    });
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
      'username': username,
      'bio': newBio,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.grey[200],
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

            return Padding(
              padding: const EdgeInsets.all(30),
              child: ListView(
                children: [
                  // profile pic
                  const SizedBox(height: 40),
                  const Icon(Icons.person, size: 100),

                  // user email
                  Text(
                    user.email!,
                    style: TextStyle(color: Colors.grey[900], fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 70),
                  // user details
                  Text('My details', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
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
                  const Divider(height: 50, color: Colors.white),
                  Text('My posts', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data?.data() == null) {
            return const Center(child: Text('Error: User does not exist'));
          } else {
            return Center(child: CircularProgressIndicator(color: Colors.grey[900]));
          }
        },
      ),
    );
  }
}

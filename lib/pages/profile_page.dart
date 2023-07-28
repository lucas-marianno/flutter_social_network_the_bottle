import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/textfield.dart';
import '../components/profile_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User user = FirebaseAuth.instance.currentUser!;
  bool isDoneLoading = false;
  String username = '';
  String bio = '';

  void getProfileInfo() async {
    var profile = await FirebaseFirestore.instance.collection('User Profile').doc(user.email).get();

    if (profile.exists) {
      username = profile.data()!['username'] ?? '';
      bio = profile.data()!['bio'] ?? '';
    } else {
      username = user.email!.split('@')[0];
      bio = 'start writing your bio';
      await FirebaseFirestore.instance.collection('User Profile').doc(user.email).set({
        'username': username,
        'bio': bio,
      });
    }
    setState(() => isDoneLoading = true);
  }

  void editUsername() async {
    final newUsername = await getNewValue(username);
    if (newUsername == null) return;
    await FirebaseFirestore.instance.collection('User Profile').doc(user.email).set({
      'username': newUsername,
      'bio': bio,
    });
    getProfileInfo();
  }

  void editBio() async {
    final newBio = await getNewValue(bio);
    if (newBio == null) return;
    await FirebaseFirestore.instance.collection('User Profile').doc(user.email).set({
      'username': username,
      'bio': newBio,
    });
    getProfileInfo();
  }

  Future<String?> getNewValue(String startingString) async {
    TextEditingController controller = TextEditingController();
    controller.text = startingString;

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[200],
        title: const Text('insert new value'),
        content: MyTextField(
          controller: controller,
          hintText: 'ahsuadhuhasuhd',
          onSubmited: () {
            Navigator.pop(context, controller.text);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, controller.text);
            },
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    getProfileInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isDoneLoading) return const Center(child: CircularProgressIndicator(color: Colors.grey));
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.grey[200],
        centerTitle: true,
        title: const Text('P R O F I L E'),
        actions: [IconButton(onPressed: getProfileInfo, icon: const Icon(Icons.replay))],
      ),
      body: Padding(
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
            ProfileField(sectionName: 'bio', text: bio, onTap: editBio),
            // my posts
            const Divider(height: 50, color: Colors.white),
            Text('My posts', style: TextStyle(color: Colors.grey[600], fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

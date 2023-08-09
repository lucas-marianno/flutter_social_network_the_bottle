import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/components/elevated_button.dart';

class Sandbox extends StatefulWidget {
  const Sandbox({super.key});

  @override
  State<Sandbox> createState() => _SandboxState();
}

class _SandboxState extends State<Sandbox> {
  final storageRef = FirebaseStorage.instance.ref();
  late final String olarURL;
  late final String olar2URL;
  bool isLoading = true;
  void getImage() async {
    olarURL = await storageRef.child('olar.jpg').getDownloadURL();
    olar2URL = await storageRef.child('Test Folder/olar2.jpg').getDownloadURL();
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    // getImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (isLoading) {
    //   return Container(
    //     color: Colors.grey[200],
    //     child: const Center(child: CircularProgressIndicator()),
    //   );
    // }
    File file = File('lib/assets/olar3.jpg');

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('S A N D B O X'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.grey[200],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Flexible(child: Image.network(olarURL)),
          // Flexible(child: Image.network(olar2URL)),
          Image.file(file),
          const SizedBox(height: 20),
          MyButton(
            text: 'upload image',
            onTap: () async {
              // storageRef.putFile(file);
            },
          )
        ],
      ),
    );
  }
}

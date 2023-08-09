import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_wall/components/elevated_button.dart';

class Sandbox extends StatefulWidget {
  const Sandbox({super.key});

  @override
  State<Sandbox> createState() => _SandboxState();
}

class _SandboxState extends State<Sandbox> {
  List<String> imageList = [];
  bool isLoading = true;

  Future<void> uploadImage(ImageSource imageSource) async {
    setState(() => isLoading = true);
    XFile? image = await ImagePicker().pickImage(source: imageSource);

    if (image == null) return;

    String newFileName = 'Test Folder/img-${DateTime.now()}';

    final uploadTask = await FirebaseStorage.instance.ref(newFileName).putFile(File(image.path));
    final newFileUrl = await uploadTask.ref.getDownloadURL();

    FirebaseFirestore.instance.collection('Test Collection').add({
      'imagePath': newFileUrl,
    });

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('S A N D B O X'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.grey[200],
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isLoading ? const LinearProgressIndicator() : Container(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Test Collection').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.network(snapshot.data!.docs[index].data()['imagePath']),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyButton(
                text: 'take a picture',
                onTap: () async {
                  uploadImage(ImageSource.camera);
                },
              ),
              MyButton(
                text: 'upload image',
                onTap: () async {
                  uploadImage(ImageSource.gallery);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

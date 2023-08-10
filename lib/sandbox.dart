import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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
  bool isLoading = false;

  Future<void> uploadImage(ImageSource imageSource) async {
    setState(() => isLoading = true);

    await () async {
      // retrieve image from user
      XFile? image = await ImagePicker().pickImage(source: imageSource, imageQuality: 50);

      if (image == null) return;

      // set filename
      String newFileName = 'Test Folder/img-${DateTime.now()}';

      //upload to storage
      late final TaskSnapshot uploadTask;
      if (kIsWeb) {
        uploadTask =
            await FirebaseStorage.instance.ref(newFileName).putData(await image.readAsBytes());
      } else {
        uploadTask = await FirebaseStorage.instance.ref(newFileName).putFile(File(image.path));
      }
      final newFileUrl = await uploadTask.ref.getDownloadURL();

      // save image URL to database
      FirebaseFirestore.instance.collection('Test Collection').add({
        'imagePath': newFileUrl,
      });
    }();

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
                        final String imagePath = snapshot.data!.docs[index].data()['imagePath'];

                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: GestureDetector(
                            onTap: () {
                              // go to full screen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FullscreenImage(imagePath),
                                ),
                              );
                            },
                            onLongPress: () {
                              // delete from database
                              FirebaseFirestore.instance
                                  .collection('Test Collection')
                                  .doc(snapshot.data!.docs[index].id)
                                  .delete();
                              // delete from storage
                              FirebaseStorage.instance.refFromURL(imagePath).delete();
                            },
                            child: Hero(
                              tag: imagePath,
                              child: Image.network(
                                imagePath,
                                scale: 0.01,
                                filterQuality: FilterQuality.low,
                              ),
                            ),
                          ),

                          /// When loading an image in a web app you need to allow (server side)
                          /// your database contents to be displayed cross origin.
                          /// -> CORS - Cross Origing Resource Sharing
                          /// this tutorial explains how to do it:
                          /// https://stackoverflow.com/questions/65653801/flutter-web-cant-load-network-image-from-another-domain
                          /// but be careful because any website can access your resources, which
                          /// can lead security leaks (and atacks from bots).
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

class FullscreenImage extends StatelessWidget {
  const FullscreenImage(
    this.imagePath, {
    super.key,
  });
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Expanded(
          child: Hero(
            tag: imagePath,
            child: Image.network(
              imagePath,
              filterQuality: FilterQuality.high,
              scale: 1,
            ),
          ),
        ),
      ),
    );
  }
}

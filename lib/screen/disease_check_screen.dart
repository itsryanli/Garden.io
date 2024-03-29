import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image_picker/image_picker.dart';

class DiseaseCheckScreen extends StatefulWidget {
  const DiseaseCheckScreen({Key? key}) : super(key: key);

  @override
  State<DiseaseCheckScreen> createState() => _DiseaseCheckScreenState();
}

class _DiseaseCheckScreenState extends State<DiseaseCheckScreen> {
  bool _loading = true;
  late File _image;
  late List _output;
  final picker = ImagePicker();
  String imageUrl = '';

  // Refer to the current user
  final user = FirebaseAuth.instance.currentUser!;

  // Reference to the Firestore collection
  late CollectionReference users;
  late DocumentReference userDocRef;

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });

    // fetch the user's UID as the document ID on startup
    users = FirebaseFirestore.instance.collection('users');
    userDocRef = users.doc(user.uid);
  }

  detectImage(File image) async {
    try {
      // print("Image Path: ${image.path}");
      var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.2,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      // print("Raw Model Output: $output");

      if (output != null) {
        setState(() {
          _output = output;
          _loading = false;
        });
        updateFirestoreWithNewImage(
            imageUrl, _output[0]['label'].split(' ').skip(1).join(' '), DateTime.now());

        // print("Model Output: $_output");
      } else {
        // print('Unable to detect image');
      }
    } catch (e) {
      // print("Error running model: $e");
    }
  }

  loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model_unquant.tflite',
        labels: 'assets/labels.txt',
      );
    } catch (e) {
      // print("Error loading model: $e");
    }
  }

  // Method to update Firestore document with a new disease entry
  Future<void> updateFirestoreWithNewImage(
      String imageUrl, String output, DateTime time) async {
    try {
      // Retrieve existing content of the 'disease' array
      var documentSnapshot = await userDocRef.get();
      if (!documentSnapshot.exists) {
        // Document doesn't exist, create a new document
        await userDocRef.set({'diseaseHistory': []});
      }
      var data = documentSnapshot.data() as Map<String, dynamic>?;

      var existingImageDiseaseHistory = data?['diseaseHistory'] ?? [];

      var newDiseaseImageEntry = {
          'imageUrl': imageUrl,
          'output': output,
          'time': time,
        };
      existingImageDiseaseHistory.add(newDiseaseImageEntry);

      // Update the Firestore document with the modified 'disease' array
      await userDocRef.update({'diseaseHistory': existingImageDiseaseHistory});
    } catch (e) {
      // print("Error updating Firestore document: $e");
    }
  }

  pickImage() async {
    XFile? imageFile = await picker.pickImage(source: ImageSource.camera);

    if (imageFile == null) return null;

    setState(() {
      _image = File(imageFile.path);
    });

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    // get a reference to storage root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    // create a reference for the image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    // handle errors/success
    try {
      // store the file
      await referenceImageToUpload.putFile(
        File(imageFile.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // success: get the download URL
      imageUrl = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      // print(error);
    }

    detectImage(_image);
  }

  pickGalleryImage() async {
    XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) return null;

    setState(() {
      _image = File(imageFile.path);
    });

    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    // get a reference to storage root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');

    // create a reference for the image to be stored
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    // handle errors/success
    try {
      // store the file
      await referenceImageToUpload.putFile(
        File(imageFile.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // success: get the download URL
      imageUrl = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      // print(error);
    }

    detectImage(_image);
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[400],
      appBar: AppBar(
        title: const Text('Disease Check'),
        backgroundColor: Colors.lightGreen[400],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Perform your disease check!',
              maxLines: 3,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(
              child: _loading
                  ? Column(
                      children: [
                        Image.asset('assets/plant.jpg',
                            width: 400, height: 400),
                        // const SizedBox(height: 50),
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: Image.file(_image),
                        ),

                        const SizedBox(height: 20),

                        _output.isNotEmpty && _output[0]['label'] != null
                            ? Text(
                                  //Only take the disease name without including the prefix number
                                'Disease: ${_output[0]['label'].split(' ').skip(1).join(' ')}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                              )
                            : Container(),
                            
                        const SizedBox(height: 10),
                      ],
                    ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Capture Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      pickGalleryImage();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Select Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

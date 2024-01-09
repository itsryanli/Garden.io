import 'dart:io';
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

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
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

  pickImage() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

    detectImage(_image);
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

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
                        _output != null &&
                                _output.isNotEmpty &&
                                _output[0]['label'] != null
                            ? Text(
                                '${_output[0]['label']}',
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
                      width: MediaQuery.of(context).size.width - 250,
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      pickGalleryImage();
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 250,
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

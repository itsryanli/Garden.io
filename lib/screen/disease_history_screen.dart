import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import 'package:intl/intl.dart';


class DiseaseHistoryScreen extends StatefulWidget {
  const DiseaseHistoryScreen({super.key});

  @override
  State<DiseaseHistoryScreen> createState() => _DiseaseHistoryScreenState();
}

class _DiseaseHistoryScreenState extends State<DiseaseHistoryScreen> {
  List<Map<String, dynamic>> diseaseHistory = [];
  String? selectedDisease;

  @override
  void initState() {
    super.initState();
    _fetchDiseaseHistory();
  }

  // Fetch recipe history data from Firestore
  Future<void> _fetchDiseaseHistory() async {
    try {
      // Retrieve the document snapshot using the user's UID
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data();

        // Retrieve the 'recipeHistory' field from the document
        var rawDiseaseHistory = data?['diseaseHistory'];

        // Check if 'recipeHistory' is a List and not null
        if (rawDiseaseHistory is List) {
          setState(() {
            // Convert each item to Map<String, dynamic>
            diseaseHistory =
                rawDiseaseHistory.cast<Map<String, dynamic>>().toList();
          });
        }
      }
    } catch (e) {
      // Handle the error as needed
      // print("Error fetching recipe history: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[400],
      appBar: AppBar(
        title: const Text('Disease History'),
        backgroundColor: Colors.lightGreen[400],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Find your disease history!',
                maxLines: 3,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // // dropdown list for recipe selection
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10.0),
              //     border: Border.all(color: Colors.black, width: 2.0),
              //   ),
              //   child: DropdownButton<String>(
              //     isExpanded: true,
              //     underline: Container(), // Remove the default underline
              //     hint: const Text(' Select a disease'),
              //     value: selectedDisease,
              //     onChanged: (String? newValue) {
              //       setState(() {
              //         selectedDisease = newValue;
              //       });
              //     },
              //     items: diseaseHistory
              //         .map<DropdownMenuItem<String>>(
              //           (Map<String, dynamic> disease) =>
              //               DropdownMenuItem<String>(
              //             value: disease['output'] as String,
              //             child: Padding(
              //               padding:
              //                   const EdgeInsets.symmetric(horizontal: 10.0),
              //               child: Text(disease['output'] as String),
              //             ),
              //           ),
              //         )
              //         .toList(),
              //   ),
              // ),

              const SizedBox(height: 10),

              // ingredients and instructions displayed
              // if (selectedDisease!= null)
                Expanded(
                  child: SingleChildScrollView(
                    child: DiseaseContent(
                      disease: diseaseHistory
                      // .firstWhere(
                      //   (disease) => disease['output'] == selectedDisease,
                      // ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String formatDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  String formattedDate = DateFormat('MMMM d, y - h:mm:ss a ', 'en_US').format(dateTime.toUtc().add(const Duration(hours: 8)));
  return formattedDate;
}

class DiseaseContent extends StatelessWidget {
  final List<Map<String, dynamic>> disease;

  const DiseaseContent({Key? key, required this.disease}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.lightGreen[100],
      ),
      child: Column(
        children: [
          // Ingredients
          const Text(
            'History:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
         const SizedBox(height: 8),
          // Use ListView.builder to display all items in the disease list
          ListView.builder(
            shrinkWrap: true, // Adjust as needed
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling
            itemCount: disease.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Text(
                    formatDate(disease[index]["time"]),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    disease[index]['output'] as String,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.center,
                    child: Image.network(
                      disease[index]['imageUrl'],
                      height: 200, // Adjust the height as needed
                      width: 200,  // Adjust the width as needed
                      fit: BoxFit.cover, // Adjust the BoxFit property as needed
                    ),
                  ),
                  const SizedBox(height: 16), // Adjust spacing between items
                ],
              );
            },
          ),

          
        ],
      ),
    );
  }
}

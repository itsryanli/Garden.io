import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gardenio/components/my_button.dart';
import 'package:gardenio/services/generate_recipe_services.dart';

class RecipesBookScreen extends StatefulWidget {
  const RecipesBookScreen({Key? key}) : super(key: key);

  @override
  State<RecipesBookScreen> createState() => _RecipesBookScreenState();
}

class _RecipesBookScreenState extends State<RecipesBookScreen> {
  late TextEditingController textController;
  late FocusNode focusNode;
  final List<String> inputTags = [];
  String response = '';

  // Refer to the current user
  final user = FirebaseAuth.instance.currentUser!;

  // Reference to the Firestore collection
  late CollectionReference users;
  late DocumentReference userDocRef;

  @override
  void initState() {
    textController = TextEditingController();
    focusNode = FocusNode();

    // fetch the user's UID as the document ID on startup
    users = FirebaseFirestore.instance.collection('users');
    userDocRef = users.doc(user.uid);

    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[400],
      appBar: AppBar(
        title: const Text('Recipes Book'),
        backgroundColor: Colors.lightGreen[400],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // title
              const Text(
                'Find the best recipe for cooking!',
                maxLines: 3,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // text field for user to insert ingredients
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      autofocus: true,
                      autocorrect: true,
                      focusNode: focusNode,
                      controller: textController,
                      onFieldSubmitted: (value) {
                        textController.clear();
                        setState(() {
                          inputTags.add(value);
                          focusNode.requestFocus();
                        });
                      },
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.5),
                            bottomLeft: Radius.circular(5.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                        labelText: "Enter the ingredients you have",
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // display the ingredients input
              SizedBox(
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    child: Wrap(
                      children: [
                        for (int i = 0; i < inputTags.length; i++)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5.0),
                            child: Chip(
                              backgroundColor: Color(
                                      (math.Random().nextDouble() * 0xFFFFFF)
                                          .toInt())
                                  .withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.5)),
                              onDeleted: () {
                                setState(() {
                                  inputTags.remove(inputTags[i]);
                                });
                              },
                              label: Text(inputTags[i]),
                              deleteIcon: const Icon(
                                Icons.close,
                                size: 15,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // response text from OpenAI
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightGreen[100],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        response,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // generate recipe button
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  child: MyButton(
                      text: "Generate Recipe",
                      onTap: () async {
                        // show user recipe is generating
                        setState(() => response = 'Thinking...');

                        var temp = await GenerateRecipeService()
                            .generateRecipe(inputTags.toString());

                        // display the content
                        setState(() {
                          response = temp.content;
                        });

                        // separate the content into three parts: title, ingredients, instructions
                        int ingredientsIndex = response.indexOf("Ingredients:");
                        int instructionsIndex =
                            response.indexOf("Instructions:");
                        if (ingredientsIndex != -1) {
                          String title =
                              response.substring(0, ingredientsIndex).trim();
                          String ingredients = response
                              .substring(
                                  ingredientsIndex + 12, instructionsIndex)
                              .trim();
                          String instructions =
                              response.substring(instructionsIndex + 13).trim();
                          // Call the method to update the Firestore document
                          await updateFirestoreWithNewRecipe(
                              title, ingredients, instructions);
                        } else {}
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to update Firestore document with a new recipe entry
  Future<void> updateFirestoreWithNewRecipe(
      String title, String ingredients, String instructions) async {
    try {
      // Retrieve existing content of the 'recipe' array
      var documentSnapshot = await userDocRef.get();
      if (!documentSnapshot.exists) {
        // Document doesn't exist, create a new document
        await userDocRef.set({'recipeHistory': []});
      }
      var data = documentSnapshot.data() as Map<String, dynamic>?;

      var existingRecipe = data?['recipeHistory'] ?? [];

      bool titleExists =
          existingRecipe.any((recipe) => recipe['title'] == title);

      if (!titleExists) {
        // Add the new recipe entry
        var newRecipeEntry = {
          'title': title,
          'ingredients': ingredients,
          'instructions': instructions
        };
        existingRecipe.add(newRecipeEntry);

        // Update the Firestore document with the modified 'recipe' array
        await userDocRef.update({'recipeHistory': existingRecipe});
      }
    } catch (e) {
      // print("Error updating Firestore document: $e");
    }
  }
}

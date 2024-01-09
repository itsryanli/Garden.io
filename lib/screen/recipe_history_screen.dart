import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class RecipeHistoryScreen extends StatefulWidget {
  const RecipeHistoryScreen({Key? key}) : super(key: key);

  @override
  State<RecipeHistoryScreen> createState() => _RecipeHistoryScreenState();
}

class _RecipeHistoryScreenState extends State<RecipeHistoryScreen> {
  List<Map<String, dynamic>> recipeHistory = [];
  String? selectedRecipe;

  @override
  void initState() {
    super.initState();
    _fetchRecipeHistory();
  }

  // Fetch recipe history data from Firestore
  Future<void> _fetchRecipeHistory() async {
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
        var rawRecipeHistory = data?['recipeHistory'];

        // Check if 'recipeHistory' is a List and not null
        if (rawRecipeHistory is List) {
          setState(() {
            // Convert each item to Map<String, dynamic>
            recipeHistory =
                rawRecipeHistory.cast<Map<String, dynamic>>().toList();
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
        title: const Text('Recipe History'),
        backgroundColor: Colors.lightGreen[400],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Find your recipe!',
                maxLines: 3,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // dropdown list for recipe selection
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: Container(), // Remove the default underline
                  hint: const Text(' Select a Recipe'),
                  value: selectedRecipe,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRecipe = newValue;
                    });
                  },
                  items: recipeHistory
                      .map<DropdownMenuItem<String>>(
                        (Map<String, dynamic> recipe) =>
                            DropdownMenuItem<String>(
                          value: recipe['title'] as String,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(recipe['title'] as String),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              const SizedBox(height: 10),

              // ingredients and instructions displayed
              if (selectedRecipe != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: RecipeContent(
                      recipe: recipeHistory.firstWhere(
                        (recipe) => recipe['title'] == selectedRecipe,
                      ),
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

class RecipeContent extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeContent({Key? key, required this.recipe}) : super(key: key);

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
            'Ingredients:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          Text(
            recipe['ingredients'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),

          const SizedBox(height: 8),

          // Instructions
          const Text(
            'Instruction:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          Text(
            recipe['instructions'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}

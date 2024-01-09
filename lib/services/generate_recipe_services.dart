import 'dart:convert';

import 'package:gardenio/models/generate_recipe_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GenerateRecipeService{
  static const baseURL = 'https://api.openai.com/v1/chat/completions';

  // connect openAI API and generate recipe
  Future<dynamic> generateRecipe(String prompt) async {

    try{
      final response = await http
      .post(
        Uri.parse(baseURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['token']}'
        },
        body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "max_tokens": 250,
            "temperature": 0,
            "top_p": 1,
            "messages": [
              {
                "role": "system",
                "content": "Create a recipe from a list of ingredients: \n$prompt",
              }
            ],
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        return GenerateRecipe.fromJson(decodedResponse);
      } 
      else {
        throw Exception(
            'Failed to load recipe. Status code: ${response.statusCode}');
      }  
    
    }catch(e){
      return e.toString();
    }
  }
}
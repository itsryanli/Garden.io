class GenerateRecipe {
  final String content;

  GenerateRecipe({
    required this.content
  });

  factory GenerateRecipe.fromJson(Map<String, dynamic> json) {
    return GenerateRecipe(
      content: json['choices'][0]['message']['content'],
    );
  }
}
class Recipe {
  final int recipeID;
  final int userID;
  final int foods;
  final int themes;
  final int cookingMethods;
  final String recipeName;
  final String content;
  final int views;

  Recipe({
    required this.recipeID,
    required this.userID,
    required this.foods,
    required this.themes,
    required this.cookingMethods,
    required this.recipeName,
    required this.content,
    required this.views,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeID: json['RecipeID'],
      userID: json['UserID'],
      foods: json['Foods'],
      themes: json['Themes'],
      cookingMethods: json['CookingMethods'],
      recipeName: json['RecipeName'],
      content: json['Content'],
      views: json['Views'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RecipeID': recipeID,
      'UserID': userID,
      'Foods': foods,
      'Themes': themes,
      'CookingMethods': cookingMethods,
      'RecipeName': recipeName,
      'Content': content,
      'Views': views,
    };
  }
}

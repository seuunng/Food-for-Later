import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/recipe_grid.dart';
import 'package:food_for_later/screens/recipe/recipe_grid_method.dart';
import 'package:food_for_later/screens/recipe/recipe_grid_theme.dart';

class AddRecipe extends StatefulWidget {
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('레시피 추가하기'),
    );
  }
}

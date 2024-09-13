import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/recipe_grid.dart';
import 'package:food_for_later/screens/recipe/recipe_grid_theme.dart';

class AddRecipe extends StatefulWidget {
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('리뷰',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('맛있어요! 간편하게 만들 수 있었어요.'),
            subtitle: Text('5분 전'),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('아이들과 함께 즐길 수 있었어요!'),
            subtitle: Text('1시간 전'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('리뷰'),

    );
  }
}

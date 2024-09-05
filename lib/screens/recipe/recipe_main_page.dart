import 'package:flutter/material.dart';

class RecipeMainPage extends StatefulWidget {
  @override
  _RecipeMainPageState createState() => _RecipeMainPageState();
}

class _RecipeMainPageState extends State<RecipeMainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피 목록'),
      ),
      body: Column(
        children: [
        ],
      ),
    );
  }
}

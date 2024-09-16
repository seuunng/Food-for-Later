import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';

class EditRecordCategories extends StatefulWidget {
  @override
  _EditRecordCategoriesState createState() => _EditRecordCategoriesState();
}

class _EditRecordCategoriesState extends State<EditRecordCategories> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기록 카테고리 관리'),
      ),
      body: Center(
      ),
    );
  }
}

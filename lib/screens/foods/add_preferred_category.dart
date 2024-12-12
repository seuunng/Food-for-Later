import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/components/navbar_button.dart';

class AddPreferredCategory extends StatefulWidget {
  final String? categoryName;
  AddPreferredCategory({this.categoryName});
  @override
  _AddPreferredCategoryState createState() =>
      _AddPreferredCategoryState();
}

class _AddPreferredCategoryState extends State<AddPreferredCategory> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController itemController = TextEditingController();
  final userId = FirebaseAuth.instance.currentUser?.uid;

  List<String> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    categoryController.text = widget.categoryName ?? ""; // 초기값 설정
    if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      _loadCategoryItems(); // Firestore에서 데이터 로드
    } else {
      isLoading = false; // 초기 카테고리가 없을 경우 로딩 상태 해제
    }
  }

  Future<void> _loadCategoryItems() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('preferred_foods_categories')
          .where('userId', isEqualTo: userId)
          .where('category.${widget.categoryName}', isGreaterThanOrEqualTo: [])
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final List<dynamic>? loadedItems = data['category'][widget.categoryName] as List<dynamic>?;

        if (loadedItems != null) {
          setState(() {
            items = List<String>.from(loadedItems);
          });
        }
      }
    } catch (e) {
      print('Error loading items: $e');
    } finally {
      setState(() {
        isLoading = false; // 로딩 상태 해제
      });
    }
  }

  void _addItem() {
    if (itemController.text.trim().isNotEmpty) {
      setState(() {
        items.add(itemController.text.trim());
        itemController.clear();
      });
    }
  }

  void _saveCategory() async {
    if (categoryController.text.trim().isEmpty || items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 이름과 아이템을 추가해주세요.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('preferred_foods_categories').add({
        'userId': userId,
        'category': {
          categoryController.text.trim(): items,
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리가 추가되었습니다.')),
      );

      setState(() {
        categoryController.clear();
        itemController.clear();
        items.clear(); // 아이템 목록 초기화
      });

      Navigator.pop(context, true);
    } catch (e) {
      print('Error saving category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 추가 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('카테고리 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: categoryController,
              decoration: InputDecoration(
                labelText: '카테고리 이름',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: itemController,
              decoration: InputDecoration(
                labelText: '아이템 추가',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addItem(),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          items.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: NavbarButton(
            buttonTitle: '선호식품 카테고리에 저장',
            onPressed: _saveCategory,
          ),
        ),
      ),
    );

  }
}

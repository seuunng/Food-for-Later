import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/components/navbar_button.dart';

class AddPreferredCategory extends StatefulWidget {
  final String? categoryName;
  final String? sourcePage;

  AddPreferredCategory({this.categoryName, this.sourcePage});

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

    if (widget.sourcePage == 'add_items') {
      // 특정 페이지에서 호출된 경우
      categoryController.text = widget.categoryName ?? "";
      if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
        _loadCategoryItems(); // Firestore에서 데이터 로드
      } else {
        setState(() {
          isLoading = false; // 카테고리 이름이 없을 경우 로딩 상태 해제
        });
      }
    } else if (widget.sourcePage == 'add_category') {
      // 다른 페이지에서 호출된 경우
      categoryController.text = ""; // 빈값 설정
      setState(() {
        isLoading = false; // 로딩 상태 해제
      });
    }
  }

  Future<void> _loadCategoryItems() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('preferred_foods_categories')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docData = snapshot.docs.first.data();

        // Firestore에서 categoryName에 해당하는 아이템을 가져오기
        final Map<String, dynamic>? categories = docData['category'] as Map<String, dynamic>?;

        if (categories != null && widget.categoryName != null) {
          final List<dynamic>? categoryItems = categories[widget.categoryName];

          if (categoryItems != null) {
            setState(() {
              items = List<String>.from(categoryItems); // 기존 아이템 로드
            });
          }
        }
      }
      setState(() {
        isLoading = false; // 로딩 상태 해제
      });
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
      final categoryName = categoryController.text.trim();

      // Firestore의 기존 데이터 가져오기
      final snapshot = await FirebaseFirestore.instance
          .collection('preferred_foods_categories')
          .where('userId', isEqualTo: userId)
          .where('category.$categoryName', isNotEqualTo: null)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docRef = snapshot.docs.first.reference;
        final existingItems = List<String>.from(
            snapshot.docs.first.data()['category'][categoryName] ?? []);

        // 기존 데이터와 현재 items를 비교하여 삭제된 아이템 찾기
        final deletedItems = existingItems.where((item) => !items.contains(item)).toList();

        // Firestore에서 삭제된 아이템 제거
        if (deletedItems.isNotEmpty) {
          final updatedItems = List<String>.from(items);
          await docRef.update({
            'category.$categoryName': updatedItems, // 업데이트된 아이템 저장
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('카테고리가 업데이트되었습니다.')),
          );
        }
      } else {
        // Firestore에 새 카테고리 추가
        await FirebaseFirestore.instance.collection('preferred_foods_categories').add({
          'userId': userId,
          'category': {
            categoryName: items, // 새 카테고리와 아이템 목록 추가
          },
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('새 카테고리가 추가되었습니다.')),
        );
      }

      // 상태 초기화 및 화면 종료
      setState(() {
        categoryController.clear();
        itemController.clear();
        items.clear();
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
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 상태 표시
          : Padding(
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

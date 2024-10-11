import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/preferred_food_model.dart';
import 'package:food_for_later/models/recipe_method_model.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';

class RecipeSearchSettings extends StatefulWidget {
  @override
  _RecipeSearchSettingsState createState() => _RecipeSearchSettingsState();
}

class _RecipeSearchSettingsState extends State<RecipeSearchSettings> {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<String> selectedSources = [];
  List<String> selectedCookingMethods = [];
  List<String> selectedPreferredFoods = [];

  TextEditingController excludeKeywordController = TextEditingController();

  List<String> sources = ['인터넷', '책', '"이따 뭐 먹지" 레시피', '기타'];
  Map<String, List<String>> cookingMethods = {};

  List<String> excludeKeywords = [];
  Map<String, List<PreferredFoodModel>> itemsByPreferredCategory = {};

  @override
  void initState() {
    super.initState();
    _loadMethodFromFirestore();
    _loadPreferredFoodsCategoriesFromFirestore();
  }

  void _loadMethodFromFirestore() async {
    try {
      final snapshot = await _db.collection('recipe_method_categories').get();
      final categories = snapshot.docs.map((doc) {
        return RecipeMethodModel.fromFirestore(doc);
      }).toList();

      // itemsByCategory에 데이터를 추가
      setState(() {
        cookingMethods = {
          for (var category in categories)
            category.categories: category.method,
        };
      });

    } catch (e) {
      print('카테고리 데이터를 불러오는 데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 데이터를 불러오는 데 실패했습니다.')),
      );
    }
  }

  void _loadPreferredFoodsCategoriesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('preferred_foods_categories')
          .get();
      final categories = snapshot.docs.map((doc) {
        return PreferredFoodModel.fromFirestore(doc);
      }).toList();

      setState(() {
        itemsByPreferredCategory = {};

        for (var categoryModel in categories) {
          // 각 categoryModel의 category 필드(Map<String, List<String>>)에서 키를 추출
          categoryModel.category.forEach((categoryName, itemList) {
            // 해당 카테고리 이름으로 itemsByPreferredCategory에 데이터를 추가
            if (itemsByPreferredCategory.containsKey(categoryName)) {
              // 이미 있는 리스트에 categoryModel을 추가
              itemsByPreferredCategory[categoryName]!.add(categoryModel);
            } else {
              // 새로운 리스트 생성 후 categoryModel 추가
              itemsByPreferredCategory[categoryName] = [categoryModel];
            }
          });
        }
      });
      print(itemsByPreferredCategory);
    } catch (e) {
      print('카테고리 데이터를 불러오는 데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 데이터를 불러오는 데 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피 검색 상세설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '조리 방법 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            for (var entry in cookingMethods.entries) // Map의 각 entry를 순회하며 빌드
              _buildMethodCategory(entry.key, entry.value),
            SizedBox(height: 16),
            // 레시피 출처 선택
            Text(
              '선호 식품 및 조리방법 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            for (var entry in itemsByPreferredCategory.entries) // Map의 각 entry를 순회하며 빌드
              _buildPreferredCategory(entry.key, entry.value),
            SizedBox(height: 16),

            // 제외 검색어 선택
            Text(
              '제외 검색어 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: excludeKeywordController,
              decoration: InputDecoration(
                hintText: '제외할 검색어를 입력하세요'
              ),
              onSubmitted: (value) {
                _addExcludeKeyword();
              },
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: excludeKeywords.map((keyword) {
                return Chip(
                  label: Text(
                    keyword,
                    style: TextStyle(
                      color: Colors.red, // 텍스트 색상 빨간색으로 변경
                      fontWeight: FontWeight.bold, // 강조를 위해 굵게 설정
                    ),
                  ),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Colors.red, // 테두리 색상 빨간색으로 변경
                      width: 1.5, // 테두리 두께 조절
                    ),
                  ),
                  onDeleted: () {
                    setState(() {
                      excludeKeywords.remove(keyword);
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50, // 버튼 높이 설정
          child: ElevatedButton(
            onPressed: () {
            },
            child: Text('설정 저장'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              textStyle: TextStyle(
                fontSize: 16, // 글씨 크기 조정
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2, //
              ),
            ),
          ),
        ),
      ),
    );
  }
// 제외 검색어 추가 함수
  void _addExcludeKeyword() {
    final keyword = excludeKeywordController.text.trim();
    if (keyword.isNotEmpty && !excludeKeywords.contains(keyword)) {
      setState(() {
        excludeKeywords.add(keyword);
      });
      excludeKeywordController.clear();
    }
  }
  // 조리 방법 카테고리 빌드 함수
  Widget _buildMethodCategory(String category, List<String> methods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: methods.map((method) {
            final isSelected = selectedCookingMethods.contains(method);
            return ChoiceChip(
              label: Text(method),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedCookingMethods.add(method);
                  } else {
                    selectedCookingMethods.remove(method);
                  }
                });
              },
              selectedColor: Colors.deepPurple[100],
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPreferredCategory(String category, List<PreferredFoodModel> models) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: models.expand((model) => model.category[category]!).map((item) {
            final isSelected = selectedPreferredFoods.contains(item);
            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedPreferredFoods.add(item);
                  } else {
                    selectedPreferredFoods.remove(item);
                  }
                });
              },
              selectedColor: Colors.deepPurple[100],
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}

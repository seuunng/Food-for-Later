import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/default_food_model.dart';
import 'package:food_for_later/models/foods_model.dart';
import 'package:food_for_later/models/fridge_category_model.dart';
import 'package:food_for_later/models/shopping_category_model.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';
import 'package:intl/intl.dart';

class AddItemToCategory extends StatefulWidget {
  final String categoryName; // 선택된 카테고리명을 받을 변수

  AddItemToCategory({required this.categoryName}); // 생성자에서 카테고리명 받기

  @override
  _AddItemToCategoryState createState() => _AddItemToCategoryState();
}

class _AddItemToCategoryState extends State<AddItemToCategory> {

  List<FoodsModel> foodsCategories = [];
  FoodsModel? selectedFoodsCategory;

  List<FridgeCategory> fridgeCategories = [];
  FridgeCategory? selectedFridgeCategory;

  List<ShoppingCategory> shoppingListCategories = [];
  ShoppingCategory? selectedShoppingListCategory;

  int expirationDays = 1; // 유통기한 기본값
  int consumptionDays = 1; // 품질유지기한 기본값

  // 입력 필드 컨트롤러
  TextEditingController foodNameController = TextEditingController();
  TextEditingController dateController = TextEditingController(); // 등록일 컨트롤러

  // 현재 날짜
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    dateController.text =
        DateFormat('yyyy-MM-dd').format(currentDate);
    _loadFoodsCategoriesFromFirestore();
    _loadFridgeCategoriesFromFirestore();
    _loadShoppingListCategoriesFromFirestore();
  }

  // 기본식품 카테고리
  void _loadFoodsCategoriesFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('foods').get();
      final categories = snapshot.docs.map((doc) {
        return FoodsModel.fromFirestore(doc);
      }).toList();

      final Map<String, FoodsModel> uniqueCategoriesMap = {};
      for (var category in categories) {
        if (!uniqueCategoriesMap.containsKey(category.defaultCategory)) {
          uniqueCategoriesMap[category.defaultCategory] = category;
        }
      }

      final uniqueCategories = uniqueCategoriesMap.values.toList();

      setState(() {
        foodsCategories = uniqueCategories;
        if (widget.categoryName.isNotEmpty) {
          selectedFoodsCategory = foodsCategories.firstWhere(
                (category) => category.defaultCategory == widget.categoryName,
            orElse: () => FoodsModel( // 기본값을 설정
            id: 'unknown',
            foodsName: '',
            defaultCategory: '',
            defaultFridgeCategory: '',
            shoppingListCategory: '',
            expirationDate: 0,
            shelfLife: 0,
            ),
          );
        }
      });
    } catch (e) {
      print("Error loading foods categories: $e");
    }
  }

  // 냉장고 카테고리
  Future<void> _loadFridgeCategoriesFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('fridge_categories').get();

    final categories = snapshot.docs.map((doc) {
      return FridgeCategory.fromFirestore(doc);
    }).toList();
    setState(() {
      fridgeCategories = categories;
    });
  }
  // 쇼핑리스트 카테고리
  Future<void> _loadShoppingListCategoriesFromFirestore() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('shopping_categories').get();

    final categories = snapshot.docs.map((doc) {
      return ShoppingCategory.fromFirestore(doc);
    }).toList();
    setState(() {
      shoppingListCategories = categories;
    });
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
        dateController.text = DateFormat('yyyy-MM-dd').format(currentDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 날짜를 "YYYY-MM-DD" 형식으로 포맷
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('기본 식품 카테고리에 추가하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: Center(child: Icon(Icons.image, size: 50)),
                ), // 이미지 추가 예시
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('카테고리명   ', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 10),
                        DropdownButton<FoodsModel>(
                          value: foodsCategories.contains(selectedFoodsCategory)
                              ? selectedFoodsCategory
                              : null,
                          hint: Text('카테고리 선택'),
                          items: foodsCategories.map((FoodsModel value) {
                            return DropdownMenuItem<FoodsModel>(
                              value: value,
                              child: Text(value.defaultCategory),
                            );
                          }).toList(),
                          onChanged: (FoodsModel? newValue) {
                            setState(() {
                              selectedFoodsCategory = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('식품명', style: TextStyle(fontSize: 18)),
                    SizedBox(
                      width: 200, // 원하는 크기로 설정
                      child: TextField(
                        controller: foodNameController,
                        decoration: InputDecoration(
                          // border: OutlineInputBorder(),
                          hintText: '식품명을 입력하세요',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.0, // 텍스트 필드 내부 좌우 여백 조절
                            vertical: 8.0, // 텍스트 필드 내부 상하 여백 조절
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('냉장고 카테고리', style: TextStyle(fontSize: 18)),
                Spacer(),
                DropdownButton<FridgeCategory>(
                  value: selectedFridgeCategory,
                  hint: Text('카테고리 선택'),
                  items: fridgeCategories.map((FridgeCategory value) {
                    return DropdownMenuItem<FridgeCategory>(
                      value: value,
                      child: Text(value.categoryName),
                    );
                  }).toList(),
                  onChanged: (FridgeCategory? newValue) {
                    setState(() {
                      selectedFridgeCategory = newValue;
                    });
                  },
                ),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('장보기 카테고리', style: TextStyle(fontSize: 18)),
                Spacer(),
                DropdownButton<ShoppingCategory>(
                  value: selectedShoppingListCategory,
                  hint: Text('카테고리 선택'),
                  items: shoppingListCategories.map((ShoppingCategory value) {
                    return DropdownMenuItem<ShoppingCategory>(
                      value: value,
                      child: Text(value.categoryName),
                    );
                  }).toList(),
                  onChanged: (ShoppingCategory? newValue) {
                    setState(() {
                      selectedShoppingListCategory = newValue;
                    });
                  },
                ),
                SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('유통기한', style: TextStyle(fontSize: 18)),
                Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (expirationDays > 1) expirationDays--;
                        });
                      },
                    ),
                    Text('$expirationDays 일', style: TextStyle(fontSize: 18)),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          expirationDays++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // 소비기한 선택 드롭다운
            Row(
              children: [
                Text('품질유지기한', style: TextStyle(fontSize: 18)),
                Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (consumptionDays > 1) consumptionDays--;
                        });
                      },
                    ),
                    Text('$consumptionDays 일', style: TextStyle(fontSize: 18)),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          consumptionDays++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('등록일', style: TextStyle(fontSize: 18)),
                Spacer(),
                SizedBox(
                  width: 150, // 필드 크기
                  child: TextField(
                    controller: dateController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '날짜 선택',
                      // border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context), // 날짜 선택 다이얼로그 호출
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
      // 하단에 추가 버튼 추가
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              if (foodNameController.text.isNotEmpty &&
                  selectedFoodsCategory != null &&
                  selectedFridgeCategory != null &&
                  selectedShoppingListCategory != null) {
                try {
                  await FirebaseFirestore.instance.collection('foods').add({
                    'foodsName': foodNameController.text, // 식품명
                    'defaultCategory': selectedFoodsCategory?.defaultCategory ?? '', // 선택된 카테고리
                    'defaultFridgeCategory': selectedFridgeCategory?.categoryName ?? '', // 냉장고 카테고리
                    'shoppingListCategory': selectedShoppingListCategory?.categoryName ?? '', // 쇼핑 리스트 카테고리
                    'expirationDate': expirationDays, // 유통기한
                    'shelfLife': consumptionDays, // 품질유지기한
                  });

                  Navigator.pop(context, true);
                } catch (e) {
                  // 저장 중 에러 발생 시 알림 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('식품 추가 중 오류가 발생했습니다: $e')),
                  );
                }
              } else {
                // 필수 입력 항목이 누락된 경우 경고 메시지 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('모든 필드를 입력해주세요.')),
                );
              }
            },
            child: Text('추가하기'),
            style: ElevatedButton.styleFrom(
              padding:
                  EdgeInsets.symmetric(vertical: 15), // 위아래 패딩을 조정하여 버튼 높이 축소
              // backgroundColor: isDeleteMode ? Colors.red : Colors.blueAccent, // 삭제 모드일 때 빨간색, 아닐 때 파란색
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게
              ),
              elevation: 5,
              textStyle: TextStyle(
                fontSize: 18, // 글씨 크기 조정
                fontWeight: FontWeight.w500, // 약간 굵은 글씨체
                letterSpacing: 1.2, //
              ),
              // primary: isDeleteMode ? Colors.red : Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}

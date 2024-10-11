import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/foods_model.dart';
import 'package:food_for_later/models/fridge_category_model.dart';
import 'package:food_for_later/models/shopping_category_model.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';
import 'package:intl/intl.dart';

class FridgeItemDetails extends StatefulWidget {
  final String foodsName;
  final String foodsCategory;
  final String fridgeCategory;
  final String shoppingListCategory;
  final int expirationDays;
  final int consumptionDays;
  final String registrationDate;

  FridgeItemDetails({
    required this.foodsName,
    required this.foodsCategory,
    required this.fridgeCategory,
    required this.shoppingListCategory,
    required this.expirationDays,
    required this.consumptionDays,
    required this.registrationDate,
  });

  @override
  _FridgeItemDetailsState createState() => _FridgeItemDetailsState();
}

class _FridgeItemDetailsState extends State<FridgeItemDetails> {

  List<FoodsModel> foodsCategories = [];
  FoodsModel? selectedFoodsCategory;

  List<FridgeCategory> fridgeCategories = [];
  FridgeCategory? selectedFridgeCategory;

  List<ShoppingCategory> shoppingListCategories = [];
  ShoppingCategory? selectedShoppingListCategory;

  Map<String, List<String>> itemsByCategory = {};

  int expirationDays = 1;
  int consumptionDays = 1;

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

    expirationDays = widget.expirationDays;
    consumptionDays = widget.consumptionDays;
    dateController.text = widget.registrationDate;
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
        if (widget.foodsCategory.isNotEmpty) {
          selectedFoodsCategory = foodsCategories.firstWhere(
                (category) => category.defaultCategory == widget.foodsCategory,
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

      selectedFridgeCategory = fridgeCategories.firstWhere(
            (category) => category.categoryName == widget.fridgeCategory,
        orElse: () => FridgeCategory(
            id: 'unknown',
            categoryName: '',
          ),
      );
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

      selectedShoppingListCategory = shoppingListCategories.firstWhere(
            (category) => category.categoryName == widget.shoppingListCategory,
        orElse: () => ShoppingCategory( // 기본 ShoppingCategory 반환
              id: 'unknown',
              categoryName: '',
            ),
      );
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

    print('defaultCategory ${widget.foodsCategory} ${selectedFoodsCategory} ');
    print('shoppingListCategory ${widget.shoppingListCategory} ${selectedShoppingListCategory}');
    print(fridgeCategories.contains(selectedFridgeCategory));
    print('defaultFridgeCategory ${widget.fridgeCategory} ${selectedFridgeCategory}');

    return Scaffold(
      appBar: AppBar(
        title: Text('상세보기'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            // 원하는 크기로 설정
                            child: TextField(
                              controller: foodNameController
                                ..text = widget.foodsName ?? '',
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '식품명을 입력하세요',
                              ),
                            ),
                          ),
                        ],
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
                    value: fridgeCategories.contains(selectedFridgeCategory)
                        ? selectedFridgeCategory
                        : null,
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
                    value: shoppingListCategories.contains(selectedShoppingListCategory)
                        ? selectedShoppingListCategory
                        : null,

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
                      Text('$consumptionDays 일',
                          style: TextStyle(fontSize: 18)),
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
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context), // 날짜 선택 다이얼로그 호출
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
      // 하단에 추가 버튼 추가
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('추가하기 버튼 클릭됨')),
              );
            },
            child: Text(
              '저장하기',
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게
              ),
              elevation: 5,
              textStyle: TextStyle(
                fontSize: 18, // 글씨 크기 조정
                fontWeight: FontWeight.w500, // 약간 굵은 글씨체
                letterSpacing: 1.2, //
              ),
            ),
          ),
        ),
      ),
    );
  }
}

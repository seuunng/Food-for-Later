import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/components/floating_add_button.dart';
import 'package:food_for_later/components/navbar_button.dart';
import 'package:food_for_later/models/default_food_model.dart';
import 'package:food_for_later/models/foods_model.dart';
import 'package:food_for_later/models/items_in_fridge.dart';
import 'package:food_for_later/models/recipe_method_model.dart';
import 'package:food_for_later/models/recipe_thema_model.dart';
import 'package:food_for_later/screens/recipe/add_recipe.dart';
import 'package:food_for_later/screens/recipe/recipe_grid.dart';
import 'package:food_for_later/screens/recipe/recipe_grid_theme.dart';
import 'package:food_for_later/screens/recipe/view_research_list.dart';
import 'package:food_for_later/screens/recipe/view_scrap_recipe_list.dart';

class RecipeMainPage extends StatefulWidget {
  final List<String> category;
  RecipeMainPage({
    required this.category,
  });
  @override
  _RecipeMainPageState createState() => _RecipeMainPageState();
}

class _RecipeMainPageState extends State<RecipeMainPage>
    with SingleTickerProviderStateMixin {
  String searchKeyword = '';
  Map<String, List<String>> itemsByCategory = {};
  List<RecipeThemaModel> themaCategories = [];
  List<String> categories = []; // 카테고리를 저장할 필드 추가
  Map<String, List<String>> methodCategories = {};
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<Tab> myTabs = <Tab>[
    Tab(text: '재료별'),
    Tab(text: '테마별'),
    Tab(text: '조리방법별'),
  ];

  // 검색된 아이템 상태를 관리할 리스트
  List<String> filteredItems = [];
  List<String> fridgeIngredients = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
    _loadCategoriesFromFirestore(); // Firestore로부터 카테고리 데이터 로드
    _loadThemaFromFirestore();  // Firestore로부터 카테고리 데이터 로드
    _loadMethodFromFirestore();
    _loadItemsInFridgeFromFirestore();
  }

  void _loadCategoriesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('foods')
          .get();

      final Map<String, List<String>> categoryMap = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final String? category = data['defaultCategory'] as String?;
        final String? foodName = data['foodsName'] as String?;

        if (category != null && foodName != null && category.isNotEmpty && foodName.isNotEmpty) {
          if (categoryMap.containsKey(category)) {
            categoryMap[category]!.add(foodName);
          } else {
            categoryMap[category] = [foodName];
          }
        }
      }

      final categories = categoryMap.keys.toList();

      setState(() {
        this.categories = categories;
        this.itemsByCategory = categoryMap; // 카테고리별 식품명 리스트
      });

    } catch (e) {
      print('카테고리 데이터를 불러오는 데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 데이터를 불러오는 데 실패했습니다.')),
      );
    }
  }

  void _loadThemaFromFirestore() async {
    try {
      final snapshot = await _db.collection('recipe_thema_categories').get();
      final themaCategories = snapshot.docs.map((doc) {
        return RecipeThemaModel.fromFirestore(doc);
      }).toList();

      setState(() {
        this.themaCategories = themaCategories;
      });
    } catch (e) {
      print('카테고리 데이터를 불러오는 데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 데이터를 불러오는 데 실패했습니다.')),
      );
    }
  }

  void _loadMethodFromFirestore() async {
    try {
      final snapshot = await _db.collection('recipe_method_categories').get();
      final categories = snapshot.docs.map((doc) {
        return RecipeMethodModel.fromFirestore(doc);
      }).toList();

      setState(() {
        methodCategories = {
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

  void _loadItemsInFridgeFromFirestore() async {
    try {
      final snapshot = await _db.collection('fridge_items').get();
      final itemsInFridge = snapshot.docs.map((doc) {
        return ItemsInFridge.fromFirestore(doc);
      }).toList();

      setState(() {
        this.fridgeIngredients = itemsInFridge.expand((item) {
          return item.items.map((itemMap) => itemMap['itemName'] ?? 'Unknown Item');
        }).toList();});

    } catch (e) {
      print('냉장고 재료를 불러오는 데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('냉장고 재료를 불러오는 데 실패했습니다.')),
      );
    }
  }

  void _searchItems(String keyword) {
    List<String> tempFilteredItems = [];
    setState(() {
      searchKeyword = keyword.trim().toLowerCase();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewResearchList(
              category: [searchKeyword],  // 필터링된 결과를 category로 넘김
            ),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: '검색어 입력',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10.0),
                    ),
                    onChanged: (value) {
                      _searchItems(value); // 검색어 입력 시 아이템 필터링
                    },
                    onSubmitted: (value) {
                      // 엔터 키를 눌렀을 때 ViewResearchList로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewResearchList(
                              category: [searchKeyword], // 필터링된 결과 전달
                            ),
                          ),
                        );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark, size: 60), // 스크랩 아이콘 크기 조정
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewScrapRecipeList(),
                      ),
                    );// 스크랩 아이콘 클릭 시 실행할 동작
                  },
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: myTabs,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RecipeGrid(
                  categories: itemsByCategory.keys.toList(),
                  itemsByCategory: itemsByCategory,
                  // physics: NeverScrollableScrollPhysics(),
                ),
                RecipeGridTheme(
                  categories: themaCategories.map((thema) => thema.categories).toList(),
                  // physics: NeverScrollableScrollPhysics(),
                ),
                RecipeGrid(
                    categories: [],
                    itemsByCategory: methodCategories,
                  // physics: NeverScrollableScrollPhysics(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: NavbarButton(
                buttonTitle: '냉장고 재료 레시피 추천',
                onPressed: () { // 람다식으로 함수 전달
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewResearchList(category: fridgeIngredients),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 20),
            // 물건 추가 버튼
            FloatingAddButton(
              heroTag: 'recipe_add_button',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRecipe(),
                    fullscreenDialog: true, // 모달 다이얼로그처럼 보이게 설정
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

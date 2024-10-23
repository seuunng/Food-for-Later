import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/recipe_model.dart';
import 'package:food_for_later/screens/recipe/read_recipe.dart';
import 'package:food_for_later/screens/recipe/view_recipe_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/preferred_food_model.dart';

class ViewResearchList extends StatefulWidget {
  final List<String> category;

  ViewResearchList({
    required this.category,
  });

  @override
  _ViewResearchListState createState() => _ViewResearchListState();
}

class _ViewResearchListState extends State<ViewResearchList> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final userId = '현재 유저아이디';
  String? selectedCategory;
  List<String> keywords = [];
  List<RecipeModel> matchingRecipes = [];

  String searchKeyword = '';

  List<String> filteredItems = [];

  double rating = 0.0;
  bool isScraped = false;
  List<String> fridgeIngredients = [];

  List<String>? selectedCookingMethods = [];
  List<String>? selectedPreferredFoodCategories = [];
  List<String>? selectedPreferredFoods = [];
  List<String>? excludeKeywords = [];

  TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    keywords.addAll(widget.category);
    _loadFridgeItemsFromFirestore();
    _loadSearchSettingsFromLocal().then((_) {
      // 검색 설정을 로드한 후, 각 카테고리에 대해 선호 식품을 불러옴
      if (selectedPreferredFoodCategories != null && selectedPreferredFoodCategories!.isNotEmpty) {
        // 모든 카테고리에 대해 선호 식품 불러오기
        for (String category in selectedPreferredFoodCategories!) {
          _loadPreferredFoodsByCategory(category).then((_) {
            // 선호 식품을 불러온 후 레시피 불러오기
            loadRecipes();
          });
        }
      } else {
        // 카테고리가 없을 경우 바로 레시피 불러오기
        loadRecipes();
      }
    });
  }

  Future<void> loadRecipes() async {
    try {
      Query query = _db.collection('recipe');

      // 선택한 조리 방법을 포함한 레시피만 필터링
      if (selectedCookingMethods != null && selectedCookingMethods!.isNotEmpty) {
        for (String method in selectedCookingMethods!) {
          query = query.where('methods', arrayContains: method);
        }
      }

      QuerySnapshot querySnapshot = await query.get();

      // 선호 식품을 포함한 레시피만 필터링
      List<DocumentSnapshot> filteredDocs = querySnapshot.docs;
      if (selectedPreferredFoods != null && selectedPreferredFoods!.isNotEmpty) {
        filteredDocs = querySnapshot.docs.where((doc) {
          List<String> foods = List<String>.from(doc['foods']);
          // 선호 식품이 있는지 확인
          return selectedPreferredFoods!.any((food) => foods.contains(food));
        }).toList();

      // 제외할 키워드를 포함하지 않는 레시피 필터링
        if (excludeKeywords != null && excludeKeywords!.isNotEmpty) {
          print('excludeKeywords 필터 시행 $excludeKeywords');
          filteredDocs = filteredDocs.where((doc) {
            List<String> foods = List<String>.from(doc['foods']);
            List<String> methods = List<String>.from(doc['methods']); // excludeKeywords에 해당하는 항목이 foods에 포함되지 않은 경우만 필터링
            List<String> items = [...foods, ...methods];
            return !excludeKeywords!.any((exclude) => items.contains(exclude));
          }).toList();
        }

      // 불러온 레시피들 matchingRecipes 리스트에 저장
        setState(() {
          matchingRecipes = filteredDocs.map((doc) {
            return RecipeModel.fromFirestore(doc.data() as Map<String, dynamic>);
          }).toList();
        });
      } else {
        // 선호 식품 필터링이 없을 경우 첫 번째 필터링 결과만 적용
        setState(() {
          matchingRecipes = querySnapshot.docs.map((doc) {
            return RecipeModel.fromFirestore(doc.data() as Map<String, dynamic>);
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading recipes: $e');
    }
  }

  Future<List<RecipeModel>> fetchRecipesByKeywords(String searchKeyword) async {
    try {
      // 검색어가 비어있지 않을 때만 필터링 적용
      if (searchKeyword.isNotEmpty) {
        List<RecipeModel> filteredRecipes = matchingRecipes.where((recipe) {
          // 레시피의 foods, methods, themes 중 하나라도 검색어를 포함하는지 확인
          return recipe.foods.any((food) => food.contains(searchKeyword)) ||
              recipe.methods.any((method) => method.contains(searchKeyword)) ||
              recipe.themes.any((theme) => theme.contains(searchKeyword));
        }).toList();

        return filteredRecipes;
      } else {
        // 검색어가 없으면 전체 목록 반환
        return matchingRecipes;
      }
    } catch (e) {
      print('Error filtering recipes: $e');
      return [];
    }
  }

  Future<void> _loadFridgeItemsFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('fridge_items').get();

      setState(() {
        fridgeIngredients =
            snapshot.docs.map((doc) => doc['items'] as String).toList();
      });
    } catch (e) {
      print('Error loading fridge items: $e');
    }
  }

  Future<bool> loadScrapedData(String recipeId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('scraped_recipes')
          .where('recipeId', isEqualTo: recipeId)
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['isScraped'] ?? false;
      } else {
        return false; // 스크랩된 레시피가 없으면 false 반환
      }
    } catch (e) {
      print("Error fetching recipe data: $e");
      return false;
    }
  }

  Future<void> _loadSearchSettingsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCookingMethods = prefs.getStringList('selectedCookingMethods');
      selectedPreferredFoodCategories = prefs.getStringList('selectedPreferredFoodCategories');
      excludeKeywords = prefs.getStringList('excludeKeywords');
    });
  }

  Future<void> _loadPreferredFoodsByCategory(String category) async {
    try {
      // Firestore에서 데이터를 불러옴
      final snapshot = await FirebaseFirestore.instance
          .collection('preferred_foods_categories')
          .get();  // 특정 category 필드 안에 있는 데이터를 가져오기 위해 전체 문서를 가져옵니다

      List<String> allFoods = [];

      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.forEach((doc) {
          // 각 문서에서 'category' 필드 안의 카테고리 이름에 맞는 배열을 불러옴
          Map<String, dynamic> categoryMap = doc['category'];

          if (categoryMap.containsKey(category)) {
            List<dynamic> foodsList = categoryMap[category]; // 해당 카테고리의 배열을 가져옴
            allFoods.addAll(foodsList.cast<String>()); // 배열을 String으로 캐스팅하여 추가
          }
        });
      }

      setState(() {
        selectedPreferredFoods = allFoods; // 불러온 식품 목록 저장
      });

      print('카테고리 "$category"에 포함된 식품 $allFoods');

    } catch (e) {
      print('Error loading preferred foods by category: $e');
    }
  }

  void _searchItems(String keyword) {
    setState(() {
      searchKeyword = keyword.trim().toLowerCase();

      if (searchKeyword.isNotEmpty && !keywords.contains(searchKeyword)) {
        keywords.add(searchKeyword);
        loadRecipes();
      }
      _searchController.clear();
    });
  }

  void _refreshRecipeData() {
    loadRecipes(); // 레시피 목록을 다시 불러오는 메서드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피 검색'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                          controller: _searchController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: '검색어 입력',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 10.0),
                          ),
                          onSubmitted: (value) {
                            _searchItems(value);
                          }),
                    ),
                    SizedBox(width: 10),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: _buildKeywords(), // 키워드 목록 위젯
            ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: _buildCategoryGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeywords() {
    return Wrap(
      spacing: 6.0,
      runSpacing: 1.0,
      children: keywords.map((keyword) {
        return Material(
          child: Chip(
            label: Text(
              keyword,
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
            deleteIcon: Icon(Icons.close, size: 16.0),
            onDeleted: () {
              setState(() {
                keywords.remove(keyword); // 키워드 삭제
                loadRecipes();
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: Colors.grey, // 테두리 색상
                width: 0.5, // 테두리 두께 조정
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryGrid() {
    if (matchingRecipes.isEmpty) {
      return Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      );
    }
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 3,
        ),
        itemCount: matchingRecipes.length,
        itemBuilder: (context, index) {
          RecipeModel recipe = matchingRecipes[index];
          String recipeName = recipe.recipeName;
          double recipeRating = recipe.rating;
          bool hasMainImage = recipe.mainImages.isNotEmpty; // 이미지가 있는지 확인

          List<String> keywordList = [
            ...recipe.foods, // 이 레시피의 food 키워드들
            ...recipe.methods, // 이 레시피의 method 키워드들
            ...recipe.themes // 이 레시피의 theme 키워드들
          ];
          return FutureBuilder<bool>(
            future: loadScrapedData(recipe.id), // 각 레시피별로 스크랩 상태를 확인
            builder: (context, snapshot) {
              bool isScraped = snapshot.data ?? false;
              // 카테고리 그리드 렌더링
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ReadRecipe(
                            recipeId: recipe.id, searchKeywords: keywords)),
                  ).then((result) {
                    if (result == true) {
                      _refreshRecipeData();
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(8.0),
                  ), // 카테고리 버튼 크기 설정

                  child: Row(
                    children: [
                      // 왼쪽에 정사각형 그림
                      Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.grey, // Placeholder color for image
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: hasMainImage
                            ? Image.network(
                                recipe.mainImages[0],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error);
                                },
                              )
                            : Icon(
                                Icons.image, // 이미지가 없을 경우 대체할 아이콘
                                size: 40,
                                color: Colors.grey,
                              ),
                      ),
                      SizedBox(width: 10), // 간격 추가
                      // 요리 이름과 키워드를 포함하는 Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Text(
                                    recipeName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Spacer(),
                                _buildRatingStars(recipeRating),
                                IconButton(
                                  icon: Icon(
                                      isScraped
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      size: 20), // 스크랩 아이콘 크기 조정
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            // 키워드
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 6.0,
                                      runSpacing: 4.0,
                                      children: keywordList.map((ingredient) {
                                        bool inFridge = fridgeIngredients
                                            .contains(ingredient);
                                        bool isKeyword =
                                            keywords.contains(ingredient);
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2.0, horizontal: 4.0),
                                          decoration: BoxDecoration(
                                            color: isKeyword
                                                ? Colors.lightGreen
                                                : inFridge
                                                    ? Colors.grey
                                                    : Colors.transparent,
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 0.5,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Text(
                                            ingredient,
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: inFridge
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor(); // 정수 부분의 별
    bool hasHalfStar = (rating - fullStars) >= 0.5; // 반 별이 필요한지 확인

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(
            Icons.star,
            color: Colors.amber,
            size: 14,
          );
        } else if (index == fullStars && hasHalfStar) {
          return Icon(
            Icons.star_half,
            color: Colors.amber,
            size: 14,
          );
        } else {
          return Icon(
            Icons.star_border,
            color: Colors.amber,
            size: 14,
          );
        }
      }),
    );
  }
}

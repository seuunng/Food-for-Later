import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/recipe_model.dart';
import 'package:food_for_later/screens/recipe/read_recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewResearchList extends StatefulWidget {
  final List<String> category;
  final bool useFridgeIngredients;

  ViewResearchList({
    required this.category,
    required this.useFridgeIngredients,
  });

  @override
  _ViewResearchListState createState() => _ViewResearchListState();
}

class _ViewResearchListState extends State<ViewResearchList> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  String? selectedCategory;
  List<String> keywords = [];
  List<RecipeModel> matchingRecipes = [];
  List<String> filteredItems = [];
  List<String> fridgeIngredients = [];
  List<String>? selectedCookingMethods = [];
  List<String>? selectedPreferredFoodCategory = [];
  List<String>? selectedPreferredFoodCategories = [];
  List<String>? selectedPreferredFoods = [];
  Map<String, List<String>> itemsByCategory = {};
  List<String>? excludeKeywords = [];

  String searchKeyword = '';
  double rating = 0.0;
  bool isScraped = false;

  Map<String, int> categoryPriority = {
    "육류": 10,
    "수산물": 9,
    "채소": 8,
    "과일": 7,
    "유제품": 6
  };

  TextEditingController _searchController = TextEditingController();
  bool useFridgeIngredientsState = false;
  // String? category = widget.category.isNotEmpty ? widget.category[0] : null;

  @override
  void initState() {
    super.initState();
    // useFridgeIngredientsState = widget.useFridgeIngredients;
    // keywords.addAll(widget.category);
    _initializeSearch();
    _loadFridgeItemsFromFirestore();
    _loadPreferredFoodsByCategory();
    _loadSearchSettingsFromLocal();
    //     .then((_) {
    //   // 검색 설정을 로드한 후, 각 카테고리에 대해 선호 식품을 불러옴
    //   if (selectedPreferredFoodCategory != null &&
    //       selectedPreferredFoodCategory!.isNotEmpty) {
    //     for (String category in selectedPreferredFoodCategory!) {
    //       _loadPreferredFoodsByCategory(category).then((_) {
    //         if (itemsByCategory.isNotEmpty) {
    //           loadRecipesByPreferredFoodsCategory();
    //         } else {
    //           _applyCategoryPriority(fridgeIngredients).then((_) {
    //             loadRecipes().then((_) {
    //               setState(() {
    //                 _searchByCategoryKeywords();
    //                 loadRecipes();
    //               });
    //             });
    //           });
    //         }
    //       });
    //     }
    //   } else {
    //     loadRecipes().then((_) {
    //       _searchByCategoryKeywords();
    //     });
    //   }
    // });
    // if (widget.category.isNotEmpty) {
    //   setState(() {
    //     for (var category in widget.category) {
    //       if (!keywords.contains(category)) {
    //         keywords.add(category);
    //       }
    //     }
    //   });
    // }
    // if (widget.useFridgeIngredients) {
    //   _loadFridgeItemsFromFirestore(); // 냉장고 재료 불러오기
    // }
  }

  // 검색 상세설정 값 불러오기
  Future<void> _loadSearchSettingsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCookingMethods = prefs.getStringList('selectedCookingMethods') ?? [];
      selectedPreferredFoodCategory =
          prefs.getStringList('selectedPreferredFoodCategories') ?? [];
      excludeKeywords = prefs.getStringList('excludeKeywords') ?? [];
      keywords.addAll(selectedCookingMethods!); // 조리 방법 키워드 추가
    });
  }

  // 냉장고 재료 불러오기
  Future<void> _loadFridgeItemsFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('fridge_items')
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        fridgeIngredients =
            snapshot.docs.map((doc) => doc['items'] as String).toList();
      });
    } catch (e) {
      print('Error loading fridge items: $e');
    }
  }

  // 냉장고 재료 우선순위에 따라 10개 추리기
  Future<List<String>> _applyCategoryPriority(List<String> fridgeIngredients) async {
    // Firestore에서 재료-카테고리 데이터를 불러옴
    Map<String, String> ingredientToCategory =
    await _loadIngredientCategoriesFromFirestore();

    // 냉장고 재료에 대해 우선순위 계산
    List<MapEntry<String, int>> prioritizedIngredients =
    fridgeIngredients.map((ingredient) {
      // 재료에 대한 카테고리를 찾음
      String category = ingredientToCategory[ingredient] ?? "";
      // 해당 카테고리의 우선순위를 찾음
      int priority = categoryPriority[category] ?? 0;

      return MapEntry(ingredient, priority);
    }).toList();

    // 우선순위에 따라 재료 정렬
    prioritizedIngredients.sort((a, b) => b.value.compareTo(a.value));

    // 최종적으로 상위 10개의 재료를 선택
    List<String> topIngredients =
    prioritizedIngredients.map((entry) => entry.key).take(10).toList();

    return topIngredients;
  }

  // 선호카테고리 불러오기
  Future<void> _loadPreferredFoodsByCategory() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('preferred_foods_categories')
          .get();

      if (snapshot.docs.isEmpty) {
        print('No data found in preferred_foods_categories.');
        return;
      }

      // 데이터 매핑
      final Map<String, List<String>> categoryData = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final Map<String, dynamic>? categories =
        data['category'] as Map<String, dynamic>?;

        if (categories != null) {
          categories.forEach((categoryName, items) {
            if (items is List<dynamic>) {
              // 카테고리와 해당 항목 리스트를 저장
              categoryData[categoryName] =
                  items.map((item) => item.toString()).toList();
            }
          });
        }
      }
      // selectedPreferredFoodCategory와 일치하는 카테고리만 필터링
      final Map<String, List<String>> filteredCategoryData = {};
      selectedPreferredFoodCategory?.forEach((category) {
        if (categoryData.containsKey(category)) {
          filteredCategoryData[category] = categoryData[category]!;
        }
      });
      // 상태 업데이트
      setState(() {
        itemsByCategory = filteredCategoryData;
      });

    } catch (e) {
      print('Error loading preferred foods by category: $e');
    }
  }

  Future<void> loadRecipesByPreferredFoodsCategory() async {
    try {
      List<String> allPreferredItems = [];
      for (String category in selectedPreferredFoodCategory!) {
        if (itemsByCategory.containsKey(category)) {
          allPreferredItems.addAll(itemsByCategory[category]!);
        }
      }

      // 제외 키워드에 추가
      setState(() {
        excludeKeywords = [...?excludeKeywords, ...allPreferredItems];
      });

      // 레시피 검색
      await _searchRecipes();
    } catch (e) {
      print('Error loading recipes by preferred foods category: $e');
    }
  }

  Future<void> _initializeSearch() async {
    await _loadSearchSettingsFromLocal();

    if (widget.useFridgeIngredients) {
      await _loadFridgeItemsFromFirestore();
      fridgeIngredients = await _applyCategoryPriority(fridgeIngredients);
      keywords.addAll(fridgeIngredients);
    }

    if (widget.category.isNotEmpty) {
      setState(() {
        keywords.addAll(widget.category.where((c) => !keywords.contains(c)));
      });
    }

    // selectedPreferredFoodCategory 처리
    if (selectedPreferredFoodCategory != null &&
        selectedPreferredFoodCategory!.isNotEmpty) {
      await loadRecipesByPreferredFoodsCategory();
    }

    // 검색 수행
    await _searchRecipes();
  }

  Future<void> _searchRecipes() async {
    List<DocumentSnapshot> results = [];

    // 키워드 검색
    for (String keyword in keywords) {
      List<QuerySnapshot> queries = await Future.wait([
        _db.collection('recipe').where('foods', arrayContains: keyword).get(),
        _db.collection('recipe').where('methods', arrayContains: keyword).get(),
        _db.collection('recipe').where('themes', arrayContains: keyword).get(),
      ]);
      for (var query in queries) {
        results.addAll(query.docs);
      }
    }

    // 중복 제거
    List<DocumentSnapshot> uniqueResults = results.toSet().toList();

    // 제외 키워드 필터링
    if (excludeKeywords != null && excludeKeywords!.isNotEmpty) {
      uniqueResults = _filterExcludedItems(
        docs: uniqueResults,
        excludeKeywords: excludeKeywords!,
      );
    }

    // 결과 상태 업데이트
    setState(() {
      matchingRecipes = uniqueResults
          .map((doc) => RecipeModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  List<DocumentSnapshot> _filterExcludedItems({
    required List<DocumentSnapshot> docs,
    required List<String> excludeKeywords,
  }) {
    return docs.where((doc) {
      List<String> foods = List<String>.from(doc['foods'] ?? []);
      List<String> methods = List<String>.from(doc['methods'] ?? []);
      List<String> themes = List<String>.from(doc['themes'] ?? []);

      return !excludeKeywords.any((exclude) =>
      foods.contains(exclude) ||
          methods.contains(exclude) ||
          themes.contains(exclude));
    }).toList();
  }

  Future<void> loadRecipes() async {
    List<RecipeModel> tempRecipes = [];
    try {
      Query query = _db.collection('recipe').orderBy('date', descending: true);
      // 선택한 조리 방법을 포함한 레시피만 필터링
      if (selectedCookingMethods != null && selectedCookingMethods!.isNotEmpty) {
        selectedCookingMethods = selectedCookingMethods!
            .where((method) => method.trim().isNotEmpty)
            .toList();
        if (selectedCookingMethods!.isNotEmpty) {
          query =
              query.where('methods', arrayContainsAny: selectedCookingMethods!);
        }
      } else {
        print('selectedCookingMethods is null or empty');
      }

      QuerySnapshot querySnapshot = await query.get();
      List<DocumentSnapshot> filteredDocs = querySnapshot.docs;

      if (keywords.isNotEmpty) {
        filteredDocs = filteredDocs.where((doc) {
          List<String> foods = List<String>.from(doc['foods'] ?? []);
          List<String> methods = List<String>.from(doc['methods'] ?? []);
          List<String> themes = List<String>.from(doc['themes'] ?? []);

          return keywords.any((keyword) {
            String lowerCaseKeyword = keyword.trim().toLowerCase();
            return foods
                    .map((food) => food.trim().toLowerCase())
                    .contains(lowerCaseKeyword) ||
                methods
                    .map((method) => method.trim().toLowerCase())
                    .contains(lowerCaseKeyword) ||
                themes
                    .map((theme) => theme.trim().toLowerCase())
                    .contains(lowerCaseKeyword);
          });
        }).toList();
      }

      List<String> excludedItems = [
        ...?excludeKeywords?.map((e) => e.trim().toLowerCase()), // 제외 키워드
        ...itemsByCategory.values.expand((items) =>
            items.map((item) => item.trim().toLowerCase())), // 카테고리 값
      ];

      print('Excluded Items: $excludedItems');

      filteredDocs = filteredDocs.where((doc) {
        List<String> foods = List<String>.from(doc['foods'] ?? []).map((food) => food.trim().toLowerCase()).toList();
        return !excludedItems.any((exclude) => foods.contains(exclude));
      }).toList();

      tempRecipes = filteredDocs
          .map((doc) {
            try {
              return RecipeModel.fromFirestore(
                  doc.data() as Map<String, dynamic>);
            } catch (e) {
              print('Error converting doc to RecipeModel: $e');
              return null;
            }
          })
          .whereType<RecipeModel>()
          .toList();

      // 결과를 상태에 반영
      setState(() {
        matchingRecipes = tempRecipes.toSet().toList();
      });

      print('Filtered Recipes: $matchingRecipes');
    } catch (e) {
      print('Error during setState for matchingRecipes: $e');
    }
  }

  Future<Map<String, String>> _loadIngredientCategoriesFromFirestore() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('foods')
          .get(); // foods 컬렉션에서 데이터 불러오기

      // Firestore 데이터에서 재료 이름과 카테고리 매핑
      Map<String, String> ingredientToCategory = {};

      for (var doc in snapshot.docs) {
        String foodsName = doc['foodsName'];
        String defaultCategory = doc['defaultCategory'];
        // 재료 이름을 key, 카테고리를 value로 설정
        ingredientToCategory[foodsName] = defaultCategory;
      }
      return ingredientToCategory; // 재료-카테고리 맵 반환
    } catch (e) {
      print("Error loading ingredient categories: $e");
      return {};
    }
  }

  // void _searchItems(String keyword) async {
  //   keyword = keyword.trim().toLowerCase();
  //   List<String> searchResults = [];
  //
  //   await _loadPreferredFoodsByCategory().then((_) {
  //     if (itemsByCategory.isNotEmpty) {
  //       loadRecipesByPreferredFoodsCategory(); // 재료들로 레시피 검색
  //     }
  //   });
  //
  //   // 1. 카테고리 이름과 일치하는지 먼저 확인
  //   bool categoryMatched = false;
  //
  //   if (itemsByCategory.isNotEmpty) {
  //     itemsByCategory.forEach((category, items) {
  //       if (category.toLowerCase() == keyword) {
  //         // 카테고리 이름이 키워드와 일치하는 경우
  //         searchResults.addAll(items); // 해당 카테고리의 모든 아이템 추가
  //         categoryMatched = true; // 카테고리 일치 확인
  //       }
  //     });
  //   }
  //
  //   // 2. 카테고리가 일치하지 않으면 일반 아이템 검색 수행
  //   if (!categoryMatched) {
  //     itemsByCategory.forEach((category, items) {
  //       // 각 아이템이 키워드와 일치하는지 확인
  //       items.forEach((item) {
  //         if (item.toLowerCase().contains(keyword)) {
  //           searchResults.add(item);
  //         }
  //       });
  //     });
  //   }
  //
  //   setState(() {
  //     searchKeyword = keyword.trim().toLowerCase();
  //     if (searchKeyword.isNotEmpty && !keywords.contains(searchKeyword)) {
  //       keywords.add(searchKeyword); // 중복 방지를 위해 검색어를 추가
  //     }
  //     _searchController.clear();
  //   });
  //
  //   if (searchKeyword.isNotEmpty) {
  //     List<RecipeModel> filteredRecipes =
  //         await fetchRecipesByKeyword(searchKeyword);
  //     setState(() {
  //       matchingRecipes = filteredRecipes;
  //     });
  //   } else {
  //     loadRecipes();
  //   }
  // }

  Future<List<RecipeModel>> fetchRecipesByKeyword(String searchKeyword) async {
    try {
      // 검색어가 비어있지 않을 때만 필터링 적용
      if (searchKeyword.isNotEmpty) {
        List<RecipeModel> filteredRecipes = matchingRecipes.where((recipe) {
          // 레시피의 foods, methods, themes 중 하나라도 검색어를 포함하는지 확인
          bool containsInFoods = recipe.foods.any((food) =>
              food.toLowerCase().contains(searchKeyword.toLowerCase()));
          bool containsInMethods = recipe.methods.any((method) =>
              method.toLowerCase().contains(searchKeyword.toLowerCase()));
          bool containsInThemes = recipe.themes.any((theme) =>
              theme.toLowerCase().contains(searchKeyword.toLowerCase()));

          // 하나라도 검색어를 포함하면 true 반환
          return containsInFoods || containsInMethods || containsInThemes;
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

  // Future<void> _searchByCategoryKeywords() async {
  //   if (keywords.isNotEmpty) {
  //     List<RecipeModel> filteredRecipes =
  //         await fetchRecipesByKeyword(keywords.join(' '));
  //     setState(() {
  //       matchingRecipes = filteredRecipes;
  //     });
  //   }
  // }

  Future<bool> loadScrapedData(recipeId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
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

  void _toggleScraped(String recipeId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      QuerySnapshot<Map<String, dynamic>> existingScrapedRecipes =
      await FirebaseFirestore.instance
          .collection('scraped_recipes')
          .where('recipeId', isEqualTo: recipeId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existingScrapedRecipes.docs.isEmpty) {
        // 스크랩이 존재하지 않으면 새로 추가
        await FirebaseFirestore.instance.collection('scraped_recipes').add({
          'userId': userId,
          'recipeId': recipeId,
          'isScraped': true,
          'scrapedGroupName': '기본함',
          'scrapedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          isScraped = true; // 스크랩 상태로 변경
        });
      } else {
        // 스크랩이 존재하면 업데이트
        DocumentSnapshot<Map<String, dynamic>> doc =
            existingScrapedRecipes.docs.first;

        await FirebaseFirestore.instance
            .collection('scraped_recipes')
            .doc(doc.id) // 문서 ID로 삭제
            .delete();

        setState(() {
          isScraped = false; // 스크랩 해제 상태로 변경
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isScraped ? '스크랩이 추가되었습니다.' : '스크랩이 해제되었습니다.'),
        ));
      }
    } catch (e) {
      print('Error scraping recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('레시피 스크랩 중 오류가 발생했습니다.'),
      ));
    }
  }

  void _saveSearchKeyword(String keyword) async {
    final searchRef = FirebaseFirestore.instance.collection('search_keywords');

    try {
      final snapshot = await searchRef.doc(keyword).get();
      if (snapshot.exists) {
        // 기존 데이터가 있으면 검색 횟수를 증가
        await searchRef.doc(keyword).update({
          'count': FieldValue.increment(1),
        });
      } else {
        // 새로운 검색어를 추가
        await searchRef.doc(keyword).set({
          'keyword': keyword,
          'count': 1,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('검색어 저장 중 오류 발생: $e');
    }
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
                            final trimmedValue = value.trim();
                            if (trimmedValue.isNotEmpty) {
                              setState(() {
                                if (!keywords.contains(trimmedValue)) {
                                  keywords.add(trimmedValue); // 새로운 키워드 추가
                                }
                              });
                              _saveSearchKeyword(trimmedValue); // 검색어 저장
                              _initializeSearch(); // 검색 실행
                              _searchController.clear();
                            }
                          }),
                    ),
                    SizedBox(width: 10),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: _buildChips(), // 키워드 목록 위젯
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

  Widget _buildChips() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 6.0,
      runSpacing: 1.0,
      children: keywords
          .where((keyword) => keyword.trim().isNotEmpty) // 빈 문자열 필터링
          .map((keyword) {
        return Chip(
          label: Text(
            keyword,
            style: TextStyle(
              fontSize: 12.0,
              color: theme.chipTheme.labelStyle?.color,
            ),
          ),
          deleteIcon: Icon(Icons.close, size: 16.0),
          onDeleted: () {
            setState(() {
              keywords.remove(keyword); // 키워드 삭제
            });
          },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                // color: Colors.grey, // 테두리 색상
                width: 0.5, // 테두리 두께 조정
              ),
            ),
          );
        }).toList(),
    );
  }

  Widget _buildFridgeIngredientsChip() {
    final theme = Theme.of(context);
    if (useFridgeIngredientsState) {
      return Chip(
        label: Text(
          "냉장고 재료",
          style: TextStyle(
            fontSize: 12.0,
            color: theme.chipTheme.labelStyle!.color,
          ),
        ),
        deleteIcon: Icon(Icons.close, size: 16.0),
        onDeleted: () {
          setState(() {
            useFridgeIngredientsState = false;
            fridgeIngredients.clear(); // 냉장고 재료 삭제
            loadRecipes(); // 레시피 다시 불러오기
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            // color: Colors.grey, // 테두리 색상
            width: 0.5, // 테두리 두께 조정
          ),
        ),
      );
    } else {
      return SizedBox.shrink(); // 빈 공간 렌더링
    }
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
                                    size: 20,
                                    color: Colors.black,
                                  ), // 스크랩 아이콘 크기 조정
                                  onPressed: () => _toggleScraped(recipe.id),
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
                                        bool isFromPreferredFoods =
                                            itemsByCategory.values.any((list) =>
                                                list.contains(ingredient));
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2.0, horizontal: 4.0),
                                          decoration: BoxDecoration(
                                            color: isKeyword ||
                                                    isFromPreferredFoods
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
                                              color: isKeyword ||
                                                      isFromPreferredFoods
                                                  ? Colors.white
                                                  : inFridge
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

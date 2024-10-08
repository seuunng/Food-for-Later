import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/recipe_model.dart';
import 'package:food_for_later/screens/recipe/read_recipe.dart';
import 'package:food_for_later/screens/recipe/view_recipe_list.dart';

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
  String? selectedCategory;
  List<String> keywords = [];
  List<RecipeModel> matchingRecipes = [];

  String searchKeyword = '';

  List<String> filteredItems = [];

  String ratings = '★★★★☆';
  bool isScraped = false; // 이미 좋아요를 눌렀는지 여부
  List<String> fridgeIngredients = ['닭고기'];

  TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 카테고리 이름을 키워드에 추가
    keywords.addAll(widget.category);
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    matchingRecipes = await fetchRecipesByKeywords(keywords);
    setState(() {});
  }

  Future<List<RecipeModel>> fetchRecipesByKeywords(
      List<String> keywords) async {
    try {
      // foods, methods, themes에서 각각 키워드를 포함하는 레시피를 검색
      QuerySnapshot foodSnapshot = await _db
          .collection('recipe')
          .where('foods', arrayContainsAny: keywords)
          .get();

      QuerySnapshot methodsSnapshot = await _db
          .collection('recipe')
          .where('methods', arrayContainsAny: keywords)
          .get();

      QuerySnapshot themesSnapshot = await _db
          .collection('recipe')
          .where('themes', arrayContainsAny: keywords)
          .get();

      // 각각의 결과를 RecipeModel 리스트로 변환
      List<RecipeModel> foodRecipes = foodSnapshot.docs.map((doc) {
        return RecipeModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      List<RecipeModel> methodRecipes = methodsSnapshot.docs.map((doc) {
        return RecipeModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      List<RecipeModel> themeRecipes = themesSnapshot.docs.map((doc) {
        return RecipeModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

      // 결과를 하나의 Set으로 결합하여 중복된 레시피를 제거
      Set<RecipeModel> allRecipes = {
        ...foodRecipes,
        ...methodRecipes,
        ...themeRecipes,
      };

      List<RecipeModel> filteredRecipes = allRecipes.where((recipe) {
        bool containsAllKeywords = keywords.every((keyword) =>
            recipe.foods.contains(keyword) ||
            recipe.methods.contains(keyword) ||
            recipe.themes.contains(keyword));
        return containsAllKeywords;
      }).toList();

      // 중복 제거된 레시피 리스트 반환
      return filteredRecipes;
    } catch (e) {
      print('Error fetching matching recipes: $e');
      return [];
    }
  }

  void _toggleScraped() {
    setState(() {
      if (isScraped) {
        isScraped = false;
      } else {
        isScraped = true;
      }
    });
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
    loadRecipes();  // 레시피 목록을 다시 불러오는 메서드
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
        bool hasMainImage = recipe.mainImages.isNotEmpty; // 이미지가 있는지 확인

        List<String> keywordList = [
          ...recipe.foods, // 이 레시피의 food 키워드들
          ...recipe.methods, // 이 레시피의 method 키워드들
          ...recipe.themes // 이 레시피의 theme 키워드들
        ];

        // 카테고리 그리드 렌더링
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReadRecipe(
                        recipeID: recipe.id, searchKeywords: keywords)),
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
              border: Border.all(color: Colors.green, width: 2),
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
                          Text(
                            recipeName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          Text(ratings),
                          IconButton(
                            icon: Icon(
                                isScraped
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                size: 20), // 스크랩 아이콘 크기 조정
                            onPressed: _toggleScraped,
                          ),
                        ],
                      ),
                      // 키워드
                      Wrap(
                        spacing: 6.0,
                        runSpacing: 1.0,
                        children: keywordList.map((ingredient) {
                          bool inFridge =
                              fridgeIngredients.contains(ingredient);
                          bool isKeyword = keywords.contains(ingredient);
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
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: inFridge ? Colors.white : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
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
  }
}

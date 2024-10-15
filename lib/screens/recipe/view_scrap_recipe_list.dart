import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/recipe_model.dart';
import 'package:food_for_later/screens/recipe/read_recipe.dart';

class ViewScrapRecipeList extends StatefulWidget {
  @override
  _ViewScrapRecipeListState createState() => _ViewScrapRecipeListState();
}

class _ViewScrapRecipeListState extends State<ViewScrapRecipeList> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final userId = '현재 유저아이디'; // 실제 유저 아이디로 대체
  String? selectedRecipe;
  String selectedFilter = '기본함';

// 요리명 리스트
  List<String> scrapedRecipes = [];
  List<RecipeModel> recipeList = [];
  List<RecipeModel> myRecipeList = []; // 나의 레시피 리스트
  // List<String> ingredients = ['닭고기', '소금', '후추'];
  String ratings = '★★★★☆';

  // 사용자별 즐겨찾기
  List<String> userFavorites = ['사용자명1', '사용자명2'];

  // 냉장고에 있는 재료 리스트
  List<String> fridgeIngredients = [];

  bool isScraped = false;

  @override
  void initState() {
    super.initState();
    fetchRecipesByScrap();
    _loadFridgeItemsFromFirestore();
  }

  // 레시피 목록 필터링 함수
  List<RecipeModel> getFilteredRecipes() {
    if (selectedFilter == '기본함') {
      return recipeList;
    }
    return myRecipeList;
  }

  Future<List<RecipeModel>> fetchRecipesByScrap() async {
    try {
      // foods, methods, themes에서 각각 키워드를 포함하는 레시피를 검색
      QuerySnapshot snapshot = await _db
          .collection('scraped_recipes')
          .where('userId', isEqualTo: userId)
          .get();

      // 각 문서의 recipeId로 레시피 정보를 불러옴
      // List<RecipeModel> recipes = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic>? data = doc.data()
            as Map<String, dynamic>?; // 데이터를 Map<String, dynamic>으로 캐스팅
        String? recipeId = data?['recipeId']; // null 안전하게 접근
        if (recipeId != null && recipeId.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> recipeSnapshot =
              await FirebaseFirestore.instance
                  .collection('recipe')
                  .doc(recipeId)
                  .get();

          if (recipeSnapshot.exists && recipeSnapshot.data() != null) {
            recipeList.add(RecipeModel.fromFirestore(recipeSnapshot.data()!));
          }
        }
      }
      return recipeList;
    } catch (e) {
      print('Error fetching matching recipes: $e');
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

  void _toggleScraped(String recipeId) async {
    try {
      // 스크랩 상태 확인을 위한 쿼리
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('스크랩 레시피 목록'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    '컬렉션',
                    style: TextStyle(
                      fontSize: 18, // 원하는 폰트 크기로 지정 (예: 18)
                      fontWeight: FontWeight.bold, // 폰트 굵기 조정 (선택사항)
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: '기본함',
                          child: Text('기본함'),
                        ),
                        // 구분선 추가
                        DropdownMenuItem(
                          enabled: false,
                          child: SizedBox(
                            height: 1, // Divider의 높이 지정
                            child: Divider(),
                          ),
                        ),
                        ...userFavorites.map((user) {
                          return DropdownMenuItem(
                            value: user,
                            child: Text(user),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: _buildRecipeGrid(),
              ),
            ),
          ],
        ));
  }

  Widget _buildRecipeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 3,
      ),
      itemCount: recipeList.length,
      itemBuilder: (context, index) {
        RecipeModel recipe = recipeList[index];
        String recipeName = recipe.recipeName;
        // bool hasImage = recipe.mainImages.isNotEmpty;
        List<String> ingredients = recipe.foods;
        List<String> methods = recipe.methods; // 조리 방법
        List<String> themes = recipe.themes;
        bool hasMainImage = recipe.mainImages.isNotEmpty;
        // 카테고리 그리드 렌더링
        return FutureBuilder<bool>(
            future: loadScrapedData(recipe.id), // 각 레시피별로 스크랩 상태를 확인
            builder: (context, snapshot) {
              bool isScraped = snapshot.data ?? false;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReadRecipe(
                                recipeId: recipe.id,
                                searchKeywords: [],
                              )));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 8.0),
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
                            // 요리명
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.3,
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
                                Text(ratings),
                                IconButton(
                                  icon: Icon(
                                      isScraped
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      size: 20), // 스크랩 아이콘 크기 조정
                                  onPressed: () => _toggleScraped(recipe.id),
                                ),
                              ],
                            ), // 간격 추가
                            // 재료
                            _buildTagSection("재료", ingredients),
                            // 조리방법
                            _buildTagSection("조리 방법", methods),
                            // 테마
                            _buildTagSection("테마", themes),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  Widget _buildTagSection(String title, List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6.0,
          runSpacing: 1.0,
          children: tags.map((tag) {
            bool inFridge = fridgeIngredients.contains(tag);
            return Container(
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              decoration: BoxDecoration(
                color: inFridge ? Colors.grey : Colors.transparent,
                border: Border.all(
                  color: Colors.grey,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12.0,
                  color: inFridge ? Colors.white : Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

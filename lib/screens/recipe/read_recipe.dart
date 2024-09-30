import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/add_recipe.dart';
import 'package:food_for_later/screens/recipe/add_recipe_review.dart';
import 'package:food_for_later/screens/recipe/recipe_review.dart';
import 'package:food_for_later/screens/recipe/report_an_issue.dart';

class ReadRecipe extends StatefulWidget {
  final String recipeID;
  final List<String> searchKeywords;

  ReadRecipe({
    required this.recipeID,
    required this.searchKeywords,
  });

  @override
  _ReadRecipeState createState() => _ReadRecipeState();
}

class _ReadRecipeState extends State<ReadRecipe> {
  List<String> ingredients = []; // 재료 목록
  String recipeName = '';
  // int serving = 0;
  // int time = 0;
  // String difficuty = '';
  List<String> mainImages = [];
  List<bool> selectedIngredients = []; // 선택된 재료 상태 저장
  List<String> shoppingList = []; // 장바구니 목록

  List<String> fridgeIngredients = ['닭고기']; // 냉장고에 있는 재료들
  List<String> searchKeywords = []; // 검색 키워드

  bool isLiked = false; // 좋아요 상태
  bool isScraped = false; // 스크랩 상태

  Future<Map<String, dynamic>> _fetchRecipeData() async {
    return await fetchRecipeData(widget.recipeID); // Firestore에서 데이터 가져오기
  }

  Future<Map<String, dynamic>> fetchRecipeData(String recipeId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('recipe')
          .doc(recipeId)
          .get();

      return snapshot.data() ?? {};
    } catch (e) {
      print("Error fetching recipe data: $e");
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    searchKeywords = widget.searchKeywords;
    print(searchKeywords);
    selectedIngredients = List.generate(ingredients.length, (index) {
      return !fridgeIngredients.contains(ingredients[index]);
    });
    _fetchInitialRecipeName();
  }

  Future<void> _fetchInitialRecipeName() async {
    var data = await fetchRecipeData(widget.recipeID);
    setState(() {
      recipeName = data['recipeName'] ?? 'Unnamed Recipe';
    });
  }

  void _toggleLike() {
    setState(() {
      if (isLiked) {
        isLiked = false;
      } else {
        isLiked = true;
      }
    });
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

  void _addToShoppingListDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text('장바구니에 추가할 재료 선택'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: ingredients.map((ingredient) {
                      int index = ingredients.indexOf(ingredient);
                      if (!fridgeIngredients.contains(ingredient)) {
                        return CheckboxListTile(
                          title: Text(ingredient),
                          value: selectedIngredients[index],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedIngredients[index] = value ?? false;
                            });
                          },
                        );
                      }
                      return SizedBox.shrink(); // 냉장고에 있는 재료는 표시하지 않음
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('취소'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('추가'),
                    onPressed: () {
                      // 선택된 재료들을 장바구니에 추가
                      for (int i = 0; i < ingredients.length; i++) {
                        if (selectedIngredients[i] &&
                            !shoppingList.contains(ingredients[i])) {
                          shoppingList.add(ingredients[i]);
                        }
                      }
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('선택한 재료를 장바구니에 추가했습니다.'),
                      ));
                    },
                  ),
                ],
              );
            },
          );
        });
  }

  void _deleteRecipe() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('레시피 삭제'),
          content: Text('정말 이 레시피를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(); // 대화상자 닫기
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () async {
                try {
                  // Firestore에서 레시피 삭제
                  await FirebaseFirestore.instance
                      .collection('recipe')
                      .doc(widget.recipeID)
                      .delete();

                  // 삭제 완료 후 대화상자를 닫고 이전 화면으로 돌아갑니다.
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true); // true 값을 반환하여 이전 화면에서 처리
                } catch (e) {
                  print('레시피 삭제 실패: $e');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('레시피 삭제에 실패했습니다. 다시 시도해주세요.'),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _refreshRecipeData() async {
    // 새로운 데이터를 가져옵니다.
    var newData = await fetchRecipeData(widget.recipeID);

    // setState로 화면을 다시 렌더링합니다.
    setState(() {
      recipeName = newData['recipeName'] ?? 'Unnamed Recipe';
      ingredients = List<String>.from(newData['foods'] ?? []);
      mainImages = List<String>.from(newData['mainImages'] ?? []);
      selectedIngredients = List.generate(ingredients.length, (index) {
        return !fridgeIngredients.contains(ingredients[index]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(recipeName),
            Spacer(),
            IconButton(
              visualDensity: const VisualDensity(horizontal: -4),
              icon: Icon(
                  isLiked
                      ? Icons.favorite
                      : Icons.favorite_border, // 상태에 따라 아이콘 변경
                  size: 30), // 스크랩 아이콘 크기 조정
              onPressed: _toggleLike,
            ),
            IconButton(
              visualDensity: const VisualDensity(horizontal: -4),
              icon: Icon(Icons.share, size: 30), // 스크랩 아이콘 크기 조정
              onPressed: () {
                // 스크랩 아이콘 클릭 시 실행할 동작
              },
            ),
            IconButton(
              visualDensity: const VisualDensity(horizontal: -4),
              icon: Icon(isScraped ? Icons.bookmark : Icons.bookmark_border,
                  size: 30), // 스크랩 아이콘 크기 조정
              onPressed: _toggleScraped,
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchRecipeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.hasData && snapshot.data != null) {
            // Firestore에서 받아온 레시피 데이터를 사용
            var data = snapshot.data!;
            List<String> ingredients = List<String>.from(data['foods'] ?? []);
            List<String> themes = List<String>.from(data['themes'] ?? []);
            List<String> methods = List<String>.from(data['methods'] ?? []);
            List<Map<String, String>> steps = List<Map<String, String>>.from(
                (data['steps'] as List<dynamic>).map((step) {
              return Map<String, String>.from(step as Map<String, dynamic>);
            }));
            recipeName = data['recipeName'] ?? 'Unnamed Recipe';
            String mainImage = data['mainImages'][0] ?? '';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(mainImage,
                      height: 400, width: 400, fit: BoxFit.cover), // 요리 완성 사진
                  _buildInfoSection(data),
                  _buildIngredientsSection(ingredients),
                  _buildCookingStepsSection(methods),
                  _buildThemesSection(themes),
                  _buildRecipeSection(steps),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Spacer(),
                      IconButton(
                        visualDensity: const VisualDensity(horizontal: -4),
                        icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 18), // 스크랩 아이콘 크기 조정
                        onPressed: _toggleLike,
                      ),
                      IconButton(
                        visualDensity: const VisualDensity(horizontal: -4),
                        icon: Icon(Icons.share, size: 18), // 스크랩 아이콘 크기 조정
                        onPressed: () {
                          // 스크랩 아이콘 클릭 시 실행할 동작
                        },
                      ),
                      IconButton(
                        visualDensity: const VisualDensity(horizontal: -4),
                        icon: Icon(
                          isScraped ? Icons.bookmark : Icons.bookmark_border,
                          size: 18,
                        ), // 스크랩 아이콘 크기 조정
                        onPressed: _toggleScraped,
                      ),
                      IconButton(
                        visualDensity: const VisualDensity(horizontal: -4),
                        icon: Icon(Icons.feedback_outlined,
                            size: 18), // 스크랩 아이콘 크기 조정
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ReportAnIssue(postNo: 1)));
                        },
                      ),
                      SizedBox(width: 4),
                      Text('|'),
                      SizedBox(width: 4),
                      Container(
                        child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddRecipe(recipeData: {
                                          'id': widget.recipeID,
                                          'recipeName': recipeName,
                                          'mainImages': List<String>.from(
                                              data['mainImages'] ?? []),
                                          'ingredients': ingredients,
                                          'themes': themes,
                                          'methods': methods,
                                          'serving': data['serving'],
                                          'cookTime': data['time'],
                                          'difficulty': data['difficulty'],
                                          'steps': steps
                                              .map((step) => {
                                                    'description':
                                                        step['description'] ??
                                                            '',
                                                    'image':
                                                        step['image'] ?? '',
                                                  })
                                              .toList(),
                                        })),
                              ).then((result) {
                                if (result == true) {
                                  // 레시피 목록을 다시 불러오거나 화면을 새로고침
                                  _refreshRecipeData(); // 레시피 데이터를 새로고침하는 메서드
                                }
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, // 버튼 패딩을 없앰
                              minimumSize: Size(40, 30), // 최소 크기 설정
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화
                            ),
                            child: Text('수정')),
                      ),
                      Container(
                        child: TextButton(
                            onPressed: _deleteRecipe,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, // 버튼 패딩을 없앰
                              minimumSize: Size(40, 30), // 최소 크기 설정
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화
                            ),
                            child: Text('삭제')),
                      ),
                    ],
                  ),
                  RecipeReview(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddRecipeReview()), // FridgeScreen은 냉장고로 이동할 화면
                        );
                      },
                      child: Text('리뷰쓰기'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // 버튼의 모서리를 둥글게
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
                  )
                ],
              ),
            );
          } else {
            return Center(child: Text("레시피를 찾을 수 없습니다."));
          }
        },
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    int servings = data['serving'] ?? 0;
    int cookTime = data['time'] ?? 0;
    String difficulty = data['difficulty'] ?? '중';
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Icon(Icons.people, size: 25),
              Text('$servings 인분'),
            ],
          ),
          Column(
            children: [
              Icon(Icons.timer, size: 25),
              Text('$cookTime 분'),
            ],
          ),
          Column(
            children: [
              Icon(Icons.emoji_events, size: 25),
              Text(difficulty),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(List<String> ingredients) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('재료',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Spacer(),
              Text("냉장고에 없는 재료 장바구니 담기"),
              _buildAddToShoppingListButton(),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: ingredients.map((ingredient) {
              bool inFridge = fridgeIngredients.contains(ingredient);
              bool isKeyword = searchKeywords.contains(ingredient);
              return Container(
                padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                decoration: BoxDecoration(
                  color: isKeyword
                      ? Colors.lightGreen
                      : inFridge
                          ? Colors.grey
                          : Colors.transparent, // 그 외는 기본 스타일
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(ingredient),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToShoppingListButton() {
    return IconButton(
      icon: Icon(Icons.add_shopping_cart),
      onPressed: _addToShoppingListDialog, // 팝업 다이얼로그 호출
    );
  }

  Widget _buildCookingStepsSection(List<String> methods) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('조리방법',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: methods.map((method) {
              bool isKeyword = searchKeywords.contains(method);
              return Container(
                padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                decoration: BoxDecoration(
                  color: isKeyword
                      ? Colors.lightGreen // 검색 키워드에 있으면 녹색
                      : Colors.transparent,
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(method),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesSection(List<String> themes) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('테마',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: themes.map((theme) {
              bool isKeyword = searchKeywords.contains(theme);
              return Container(
                padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                decoration: BoxDecoration(
                  color: isKeyword
                      ? Colors.lightGreen // 검색 키워드에 있으면 녹색
                      : Colors.transparent,
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(theme),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeSection(List<Map<String, String>> steps) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('레시피',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, index) {
              bool hasImage = steps[index]['image'] != null &&
                  steps[index]['image']!.isNotEmpty;
              return Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      hasImage
                          ? Image.network(
                              steps[index]['image']!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text('Error loading image');
                              },
                            )
                          : Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey, // 이미지가 없을 때 회색 배경
                              child: Icon(Icons.image, color: Colors.white),
                            ),
                      Expanded(
                        child: Center(
                            child: Text(steps[index]['description']!,
                                textAlign: TextAlign.center)),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

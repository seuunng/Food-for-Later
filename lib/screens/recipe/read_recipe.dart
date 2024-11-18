import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/components/navbar_button.dart';
import 'package:food_for_later/screens/recipe/add_recipe.dart';
import 'package:food_for_later/screens/recipe/add_recipe_review.dart';
import 'package:food_for_later/screens/recipe/recipe_review.dart';
import 'package:food_for_later/screens/recipe/report_an_issue.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReadRecipe extends StatefulWidget {
  final String recipeId;
  final List<String> searchKeywords;

  ReadRecipe({
    required this.recipeId,
    required this.searchKeywords,
  });

  @override
  _ReadRecipeState createState() => _ReadRecipeState();
}

class _ReadRecipeState extends State<ReadRecipe> {
  List<String> ingredients = []; // 재료 목록
  String recipeName = '';
  int views=0;
  // int serving = 0;
  // int time = 0;
  // String difficuty = '';
  List<String> mainImages = [];
  List<bool> selectedIngredients = []; // 선택된 재료 상태 저장
  List<String> shoppingList = []; // 장바구니 목록

  List<String> fridgeIngredients = []; // 냉장고에 있는 재료들
  List<String> searchKeywords = []; // 검색 키워드

  bool isLiked = false; // 좋아요 상태
  bool isScraped = false; // 스크랩 상태

  PageController _pageController = PageController();
  int _currentPage = 0;



  @override
  void initState() {
    super.initState();
    searchKeywords = widget.searchKeywords;
    selectedIngredients = List.generate(ingredients.length, (index) {
      return !fridgeIngredients.contains(ingredients[index]);
    });
    _fetchInitialRecipeName();
    loadScrapedData(widget.recipeId);
    loadLikedData(widget.recipeId);
    _increaseViewCount(widget.recipeId);
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose(); // 페이지 컨트롤러 해제
    super.dispose();
  }
  Future<Map<String, dynamic>> _fetchRecipeData() async {
    return await fetchRecipeData(widget.recipeId); // Firestore에서 데이터 가져오기
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
  Future<void> _fetchInitialRecipeName() async {
    var data = await fetchRecipeData(widget.recipeId);
    setState(() {
      recipeName = data['recipeName'] ?? 'Unnamed Recipe';
      mainImages = List<String>.from(data['mainImages'] ?? []); // mainImages 업데이트
    });
  }

  Future<void> loadScrapedData(String recipeId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('scraped_recipes')
          .where('recipeId', isEqualTo: recipeId)
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        isScraped = snapshot.docs.first.data()['isScraped'] ?? false;
      });
    } catch (e) {
      print("Error fetching recipe isScraped data: $e");
    }
  }

  Future<void> loadLikedData(String recipeId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('liked_recipes')
          .where('recipeId', isEqualTo: recipeId)
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        isScraped = snapshot.docs.first.data()['isLiked'] ?? false;
      });
    } catch (e) {
      print("Error fetching recipe isLiked data: $e");
    }
  }

  void _toggleLike() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      // 스크랩 상태 확인을 위한 쿼리
      QuerySnapshot<Map<String, dynamic>> existingScrapedRecipes =
          await FirebaseFirestore.instance
              .collection('liked_recipes')
              .where('recipeId', isEqualTo: widget.recipeId)
              .where('userId', isEqualTo: userId)
              .get();

      if (existingScrapedRecipes.docs.isEmpty) {
        // 스크랩이 존재하지 않으면 새로 추가
        await FirebaseFirestore.instance.collection('liked_recipes').add({
          'userId': userId,
          'recipeId': widget.recipeId,
          'isLiked': true,
        });

        setState(() {
          isLiked = true; // 스크랩 상태로 변경
        });
      } else {
        DocumentSnapshot<Map<String, dynamic>> doc =
            existingScrapedRecipes.docs.first;
        bool currentIsScraped = doc.data()?['isLiked'] ?? false;

        await FirebaseFirestore.instance
            .collection('liked_recipes')
            .doc(doc.id)
            .update({'isLiked': !currentIsScraped});

        setState(() {
          isLiked = !currentIsScraped; // 스크랩 상태 변경
        });
      }
    } catch (e) {
      print('Error scraping recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('레시피 스크랩 중 오류가 발생했습니다.'),
      ));
    }
  }

  void _toggleScraped() async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      QuerySnapshot<Map<String, dynamic>> existingScrapedRecipes =
          await FirebaseFirestore.instance
              .collection('scraped_recipes')
              .where('recipeId', isEqualTo: widget.recipeId)
              .where('userId', isEqualTo: userId)
              .get();

      if (existingScrapedRecipes.docs.isEmpty) {
        // 스크랩이 존재하지 않으면 새로 추가
        await FirebaseFirestore.instance.collection('scraped_recipes').add({
          'userId': userId,
          'recipeId': widget.recipeId,
          'isScraped': true,
        });

        setState(() {
          isScraped = true; // 스크랩 상태로 변경
        });
      } else {
        // 스크랩이 존재하면 업데이트
        DocumentSnapshot<Map<String, dynamic>> doc =
            existingScrapedRecipes.docs.first;
        bool currentIsScraped = doc.data()?['isScraped'] ?? false;

        await FirebaseFirestore.instance
            .collection('scraped_recipes')
            .doc(doc.id)
            .update({'isScraped': !currentIsScraped});

        setState(() {
          isScraped = !currentIsScraped; // 스크랩 상태 변경
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

  void _addToShoppingListDialog() async {
    Future<void> _addToShoppingList(List<String> ingredients) async {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      try {
        for (int i = 0; i < ingredients.length; i++) {
          if (selectedIngredients[i] &&
              !shoppingList.contains(ingredients[i])) {
            final existingItemSnapshot = await FirebaseFirestore.instance
                .collection('shopping_items')
                .where('items', isEqualTo: ingredients[i])
                .where('userId', isEqualTo: userId) // 현재 유저의 아이템만 확인
                .get();

            if (existingItemSnapshot.docs.isEmpty) {
              // 중복되지 않은 경우에만 추가
              await FirebaseFirestore.instance
                  .collection('shopping_items')
                  .add({
                'items': ingredients[i],
                'isChecked': false, // 체크되지 않은 상태로 저장
                'userId': userId, // 사용자 ID
              });
            } else {
              print('"${ingredients[i]}"이(가) 이미 장바구니에 있습니다.');
            }
          }
        }
      } catch (e) {
        print('Error adding items to shopping list: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('장바구니에 추가하는 도중 오류가 발생했습니다.'),
        ));
      }
    }

    void _showAddToShoppingListDialog(List<String> ingredients) {
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
                      return SizedBox.shrink();
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
                      _addToShoppingList(ingredients);
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
        },
      );
    }

    Future<void> _loadFridgeItemsFromFirestore() async {
      try {
        var recipeData = await fetchRecipeData(widget.recipeId);
        List<String> ingredients = List<String>.from(recipeData['foods'] ?? []);

        final snapshot =
            await FirebaseFirestore.instance.collection('fridge_items').get();

        setState(() {
          fridgeIngredients =
              snapshot.docs.map((doc) => doc['items'] as String).toList();
          selectedIngredients = List<bool>.filled(ingredients.length, true);
        });

        if (ingredients.isNotEmpty) {
          _showAddToShoppingListDialog(ingredients);
        } else {
          print('Ingredients 배열이 비어있습니다.');
        }
      } catch (e) {
        print('Error loading fridge items: $e');
      }
    }

    _loadFridgeItemsFromFirestore(); // 데이터를 모두 로드한 후에 다이얼로그를 표시
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
                // bool isScraped = recipe[index]['isScraped'] ?? false;
                // bool isLiked = recipe[index]['isLiked'] ?? false;

                try {
                  await FirebaseFirestore.instance
                      .collection('recipe')
                      .doc(widget.recipeId)
                      .delete();

                  // 관련된 스크랩된 데이터 삭제
                  QuerySnapshot<Map<String, dynamic>> scrapedRecipesSnapshot =
                  await FirebaseFirestore.instance
                      .collection('scraped_recipes')
                      .where('recipeId', isEqualTo: widget.recipeId)
                      .get();

                  for (var doc in scrapedRecipesSnapshot.docs) {
                    await FirebaseFirestore.instance
                        .collection('scraped_recipes')
                        .doc(doc.id)
                        .delete();
                  }

                  // 관련된 좋아요 데이터 삭제
                  QuerySnapshot<Map<String, dynamic>> likedRecipesSnapshot =
                  await FirebaseFirestore.instance
                      .collection('liked_recipes')
                      .where('recipeId', isEqualTo: widget.recipeId)
                      .get();

                  for (var doc in likedRecipesSnapshot.docs) {
                    await FirebaseFirestore.instance
                        .collection('liked_recipes')
                        .doc(doc.id)
                        .delete();
                  }


                  Navigator.of(context).pop();
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

  Future<void> _increaseViewCount(String recipeId) async {
    try {
      DocumentReference recipeDoc =
      FirebaseFirestore.instance.collection('recipe').doc(recipeId);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(recipeDoc);

        if (!snapshot.exists) {
          throw Exception("레시피 문서가 존재하지 않습니다.");
        }

        int currentViewCount = snapshot['views'] ?? 0;

        // 조회수 증가
        transaction.update(recipeDoc, {'views': currentViewCount + 1});
      });
    } catch (e) {
      print("조회수 증가 중 오류 발생: $e");
    }
  }

  void _refreshRecipeData() async {
    var newData = await fetchRecipeData(widget.recipeId);

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
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Text(
                recipeName,
                maxLines: 1, // 최대 1줄만 보여줌
                overflow: TextOverflow.ellipsis, // 넘칠 경우 말줄임표로 표시
              ),
            ),
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
            List<String> mainImages =
                List<String>.from(data['mainImages'] ?? []);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainImageSection(mainImages),
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
                                      ReportAnIssue(
                                          postNo: widget.recipeId,
                                          postType: '레시피',
                                      )));
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
                                          'id': widget.recipeId,
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
                  RecipeReview(
                    recipeId: widget.recipeId,
                  ),
                  Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: NavbarButton(
                        buttonTitle: '리뷰쓰기',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddRecipeReview(
                                recipeId: widget.recipeId,
                              ),
                            ),
                          );
                        },
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

  Widget _buildMainImageSection(List<String> mainImages) {
    if (mainImages.isEmpty) {
      return Container(
        height: 400,
        color: Colors.grey, // 이미지가 없을 경우 배경색을 회색으로 설정
        child: Icon(Icons.image, color: Colors.white, size: 100), // 대체 아이콘
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _pageController,
            itemCount: mainImages.length,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index; // 현재 페이지를 저장
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                mainImages[index], // 현재 페이지의 이미지 URL
                width: double.infinity,
                fit: BoxFit.cover, // 이미지를 꽉 채우도록 설정
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                      child: Icon(Icons.error,
                          color: Colors.red, size: 100)); // 이미지 로딩 실패 시 아이콘 표시
                },
              );
            },
          ),
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(mainImages.length, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 5),
              width: _currentPage == index ? 12 : 8,
              height: _currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.black
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> data) {
    int servings = data['serving'] ?? 0;
    int cookTime = data['time'] ?? 0;
    String difficulty = data['difficulty'] ?? '중';
    int viewCount = data['views'] ?? 0;
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
          Column(
            children: [
              Icon(Icons.remove_red_eye_sharp, size: 25),
              Text('$viewCount명 읽음'),  // 조회수 표시
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

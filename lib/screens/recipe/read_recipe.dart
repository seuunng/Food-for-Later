import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/add_recipe.dart';
import 'package:food_for_later/screens/recipe/recipe_review.dart';
import 'package:food_for_later/screens/recipe/report_an_issue.dart';

class ReadRecipe extends StatefulWidget {
  final String recipeName;

  ReadRecipe({
    required this.recipeName,
  });

  @override
  _ReadRecipeState createState() => _ReadRecipeState();
}

class _ReadRecipeState extends State<ReadRecipe> {
  int selectedServings = 2;
  int cookTime = 30;
  String difficulty = '중';
  List<String> ingredients = ['닭고기', '양파', '간장', '설탕'];
  List<String> cookingSteps = ['재료 손질', '고기 굽기', '소스 만들기'];
  List<String> themes = ['저칼로리', '한식', '간단한 요리'];

  List<String> fridgeIngredients = ['닭고기'];

  List<Map<String, String>> recipeSteps = [
    {'image': 'assets/step1.jpeg', 'description': '재료를 손질합니다.'},
    {'image': 'assets/step2.jpeg', 'description': '닭고기를 굽습니다.'},
    {'image': 'assets/step3.jpeg', 'description': '소스를 만듭니다.'},
  ];

  bool isLiked = false; // 이미 좋아요를 눌렀는지 여부
  bool isScraped = false; // 이미 좋아요를 눌렀는지 여부

  // 좋아요 버튼 클릭 시 호출되는 함수
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

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Icon(Icons.people, size: 25),
              Text('$selectedServings 인분'),
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

  Widget _buildIngredientsSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('재료',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 10,
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: ingredients.map((ingredient) {
              bool inFridge = fridgeIngredients.contains(ingredient);
              return Container(
                padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                decoration: BoxDecoration(
                  color: inFridge ? Colors.grey : Colors.transparent,
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

  Widget _buildCookingStepsSection() {
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
            children: cookingSteps.map((step) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(step),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesSection() {
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
              return Container(
                padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
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

  Widget _buildRecipeSection() {
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
            itemCount: recipeSteps.length,
            itemBuilder: (context, index) {
              bool hasImage = recipeSteps[index]['image'] != null &&
                  recipeSteps[index]['image']!.isNotEmpty;
              return Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      hasImage
                          ? Image.asset(
                              recipeSteps[index]['image']!,
                              width: 150,
                              height: 150,
                            )
                          : Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey, // 이미지가 없을 때 회색 배경
                              child: Icon(Icons.image, color: Colors.white),
                            ),
                      Expanded(
                        child: Center(
                            child: Text(recipeSteps[index]['description']!,
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
  void _deleteRecipe() {
    // 삭제 동작을 여기에 정의합니다. 데이터베이스나 서버에서 레시피 삭제 요청을 보내는 로직을 추가할 수 있습니다.
    // 예시로는 현재 페이지에서 pop으로 돌아가는 동작을 수행합니다.

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
              onPressed: () {
                // 실제 삭제 로직을 여기에 추가합니다.
                // 예를 들어 데이터베이스에서 레시피 삭제 로직을 추가할 수 있습니다.
                Navigator.of(context).pop(); // 대화상자 닫기
                Navigator.of(context).pop(); // 이전 화면으로 돌아가기
              },
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.recipeName),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/recipe_image.jpeg',
                height: 400, width: 400, fit: BoxFit.cover), // 요리 완성 사진
            _buildInfoSection(),
            _buildIngredientsSection(),
            _buildCookingStepsSection(),
            _buildThemesSection(),
            _buildRecipeSection(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Spacer(),
                IconButton(
                  visualDensity: const VisualDensity(horizontal: -4),
                  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
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
                  icon:
                      Icon(Icons.feedback_outlined, size: 18), // 스크랩 아이콘 크기 조정
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReportAnIssue(postNo: 1)));
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
                                builder: (context) => AddRecipe(recipeData: {
                                      'recipeName': widget.recipeName,
                                      'ingredients': ingredients,
                                      'cookingSteps': cookingSteps,
                                      'themes': themes,
                                      'servings': selectedServings,
                                      'cookTime': cookTime,
                                      'difficulty': difficulty,
                                      'recipeSteps': recipeSteps.map((step) => {
                                                'description': step['description'] ?? '',
                                                'image': step['image'] ?? '',
                                              }).toList(),
                                    })));
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
          ],
        ),
      ),
    );
  }
}

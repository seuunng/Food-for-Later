import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/recipe_review.dart';

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
  String difficulty = '중간';
  List<String> ingredients = ['닭고기', '양파', '간장', '설탕'];
  List<String> cookingSteps = ['재료 손질', '고기 굽기', '소스 만들기'];
  List<String> themes = ['저칼로리', '한식', '간단한 요리'];

  List<String> fridgeIngredients = ['닭고기'];

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
    List<Map<String, String>> recipeSteps = [
      {'image': 'assets/step1.jpeg', 'description': '재료를 손질합니다.'},
      {'image': 'assets/step2.jpeg', 'description': '닭고기를 굽습니다.'},
      {'image': 'assets/step3.jpeg', 'description': '소스를 만듭니다.'},
    ];
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
              icon: Icon(Icons.favorite_border, size: 30), // 스크랩 아이콘 크기 조정
              onPressed: () {
                // 스크랩 아이콘 클릭 시 실행할 동작
              },
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
              icon: Icon(Icons.bookmark_border, size: 30), // 스크랩 아이콘 크기 조정
              onPressed: () {
                // 스크랩 아이콘 클릭 시 실행할 동작
              },
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
                  icon: Icon(Icons.favorite_border, size: 18), // 스크랩 아이콘 크기 조정
                  onPressed: () {
                    // 스크랩 아이콘 클릭 시 실행할 동작
                  },
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
                  icon: Icon(Icons.bookmark_border, size: 18,), // 스크랩 아이콘 크기 조정
                  onPressed: () {
                    // 스크랩 아이콘 클릭 시 실행할 동작
                  },
                ),
                IconButton(
                  visualDensity: const VisualDensity(horizontal: -4),
                  icon:
                      Icon(Icons.feedback_outlined, size: 18), // 스크랩 아이콘 크기 조정
                  onPressed: () {
                    // 스크랩 아이콘 클릭 시 실행할 동작
                  },
                ),
                IconButton(
                  visualDensity: const VisualDensity(horizontal: -4),
                  icon: Icon(Icons.print, size: 18), // 스크랩 아이콘 크기 조정
                  onPressed: () {
                    // 스크랩 아이콘 클릭 시 실행할 동작
                  },
                ),
                SizedBox(width: 4),
                Text('|'),
                SizedBox(width: 4),
                Container(
                    child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // 버튼 패딩을 없앰
                          minimumSize: Size(40, 30), // 최소 크기 설정
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화
                        ),
                        child: Text('수정')),
                ),
                Container(
                    child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero, // 버튼 패딩을 없앰
                          minimumSize: Size(40, 30), // 최소 크기 설정
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화
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

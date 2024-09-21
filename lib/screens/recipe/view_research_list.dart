import 'package:flutter/material.dart';
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
  String? selectedCategory;
  Map<String, List<String>> itemsByCategory = {
    '집밥백선생': ['소고기', '돼지고기', '닭고기'],
    '손님맞이': ['연어', '참치', '고등어'],
    '다이어트': ['참치오이비빔밥', '독일국수', '오트밀미역죽', '버섯리조또']
  };

  List<String> keywords = ['고기', '해산물', '다이어트'];

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 카테고리 이름을 키워드에 추가
    keywords.addAll(widget.category);
  }

  // 선택된 아이템 상태를 관리할 리스트
  List<String> getRecipes() {
    List<String> allRecipes = [];

    for (String category in widget.category) {
      if (itemsByCategory.containsKey(category)) {
        allRecipes.addAll(itemsByCategory[category]!);
      }
    }

    return allRecipes;
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
    List<String> recipeList = getRecipes();
    if (recipeList.isEmpty) {
      return Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: TextStyle(fontSize: 14, ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 5,
      ),
      itemCount: recipeList.length,
      itemBuilder: (context, index) {
        String recipeName = recipeList[index];
        String keyword = "키워드";
        bool hasImage = false;
        // 카테고리 그리드 렌더링
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ViewRecipeList(recipeName: recipeName)));
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
                SizedBox(height: 65),
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: Colors.grey, // Placeholder color for image
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: hasImage
                      ? Image.asset(
                          'assets/images/recipe_placeholder.png', // 이미지 경로
                          fit: BoxFit.cover,
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
                      Text(
                        recipeName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4), // 간격 추가
                      // 키워드
                      Text(
                        keyword, // 실제 키워드로 대체 가능
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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
  }

  String searchKeyword = '';

  List<String> filteredItems = [];

  void _searchItems(String keyword) {
    List<String> tempFilteredItems = [];
    setState(() {
      searchKeyword = keyword.trim().toLowerCase();

      if (searchKeyword.isNotEmpty && !keywords.contains(searchKeyword)) {
        keywords.add(searchKeyword);
      }

      filteredItems = [];
      itemsByCategory.forEach((category, items) {
        filteredItems.addAll(
          items.where((item) => item.toLowerCase().contains(searchKeyword)),
        );
      });
    });
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
              padding: const EdgeInsets.all(8.0),
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
}

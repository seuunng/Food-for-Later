import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/view_recipe_list.dart';
import 'package:food_for_later/screens/recipe/view_research_list.dart';

class RecipeGridTheme extends StatefulWidget {
  final List<String> categories;

  RecipeGridTheme({
    required this.categories,
  });

  @override
  _RecipeGridThemeState createState() => _RecipeGridThemeState();
}

class _RecipeGridThemeState extends State<RecipeGridTheme> {
  String? selectedCategory;

  // 선택된 아이템 상태를 관리할 리스트
  List<String> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: _buildCategoryGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final theme = Theme.of(context);
    if (widget.categories.isEmpty) {
      // 기본 카테고리가 비어있을 때 처리
      return Center(child: Text("카테고리가 없습니다."));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // 한 줄에 3칸
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 6,
      ),
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        String category = widget.categories[index];
        // String currentItem = selectedItems[index];
        // 카테고리 그리드 렌더링
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewResearchList(
                      category: [category],
                      useFridgeIngredients: false,
                    )));
          },
          child: Container(
            decoration: BoxDecoration(
              color: selectedCategory == category
                  ? theme.chipTheme.selectedColor
                  : theme.chipTheme.backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ), // 카테고리 버튼 크기 설정
            // height: 60,
            // margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                category,
                style: TextStyle(color: theme.chipTheme.labelStyle!.color, fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }
}

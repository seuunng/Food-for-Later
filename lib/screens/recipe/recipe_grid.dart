import 'package:flutter/material.dart';

class RecipeGrid extends StatefulWidget {
  final List<String> categories;
  final Map<String, List<String>> itemsByCategory;

  RecipeGrid({
    required this.categories,
    required this.itemsByCategory,
  });

  @override
  _RecipeGridState createState() => _RecipeGridState();
}

class _RecipeGridState extends State<RecipeGrid> {
  String? selectedCategory;

  // 선택된 아이템 상태를 관리할 리스트
  List<String> selectedItems = [];

  @override
  void initState() {
    super.initState();
    // 카테고리가 비어있을 경우 첫 번째 아이템으로 selectedCategory 설정
    if (widget.categories.isEmpty && widget.itemsByCategory.isNotEmpty) {
      selectedCategory = widget.itemsByCategory.keys.first;
    }
  }

  Widget _buildCategoryGrid() {
    if (widget.categories.isEmpty) {
      // 기본 카테고리가 비어있을 때 처리
      return Container();
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 한 줄에 3칸
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1,
      ),
      itemCount: widget.categories.length,
      itemBuilder: (context, index) {
        String category = widget.categories[index];
        // String currentItem = selectedItems[index];
        // 카테고리 그리드 렌더링
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = selectedCategory == category ? null : category;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: selectedCategory == category ? Colors.orange : Colors.blueAccent,
              borderRadius: BorderRadius.circular(8.0),
            ), // 카테고리 버튼 크기 설정
            // height: 60,
            // margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                category,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItemsGrid() {
    if (selectedCategory == null) {
      return Container();
    }

    List<String> items = widget.itemsByCategory[selectedCategory!] ?? [];

    return GridView.builder(
      shrinkWrap: true,
      // GridView의 크기를 콘텐츠에 맞게 줄임
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 한 줄에 3칸
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        String currentItem = items[index];
          // 기존 아이템 그리드 렌더링
          return GestureDetector(
            onTap: () {

            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              height: 60,
              child: Center(
                child: Text(
                  currentItem,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: _buildCategoryGrid(),
          ),
          if (!widget.categories.isEmpty && selectedCategory != null) ...[
            Divider(thickness: 2),
          ],
          if (selectedCategory != null) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildCategoryItemsGrid(),
            ),
          ],
        ],
      ),
    );
  }
}

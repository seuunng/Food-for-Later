import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';

class AddIitem extends StatefulWidget {
  @override
  _AddIitemState createState() => _AddIitemState();
}

class _AddIitemState extends State<AddIitem> {
// 상수 리스트로 처리
  static const List<String> basicFoodsCategories = [
    '육류',
    '수산물',
    '채소',
    '과일',
    '견과'
  ];

  String? selectedCategory;
  String searchKeyword = '';

  // 각 카테고리별 아이템 리스트 (예시 데이터)
  Map<String, List<String>> itemsByCategory = {
    '육류': ['소고기', '돼지고기', '닭고기'],
    '수산물': ['연어', '참치', '고등어'],
    '채소': ['양파', '당근', '감자'],
    '과일': [
      '사과',
      '바나나',
      '포도',
      '메론',
      '자몽',
      '블루베리',
      '라즈베리',
      '딸기',
      '체리',
      '오렌지',
      '골드키위',
      '참외',
      '수박',
      '감',
      '복숭아',
      '앵두',
      '자두',
      '배',
      '코코넛',
      '리치',
      '망고',
      '망고스틴',
      '아보카도',
      '복분자',
      '포도',
      '샤인머스캣',
      '용과',
      '라임',
      '레몬',
      '천도복숭아',
      '파인애플',
      '애플망고',
      '잭프릇',
      '람보탄',
      '아사히베리',
      ''
    ],
    '견과': ['아몬드', '호두', '캐슈넛'],
  };

  // 냉장고에 추가된 아이템 리스트
  List<String> fridgeItems = [];

  // 선택된 아이템 상태를 관리할 리스트
  List<String> selectedItems = [];

  // 검색된 아이템 상태를 관리할 리스트
  List<String> filteredItems = [];

  // 물건 추가 다이얼로그 (더블 클릭으로 추가)
  Future<void> _addItemsToFridge() async {
    setState(() {
      fridgeItems
          .addAll(selectedItems.where((item) => !fridgeItems.contains(item)));
      selectedItems.clear(); // 선택된 아이템 목록 초기화
    });
  }

  // 검색 로직
  void _searchItems(String keyword) {
    setState(() {
      searchKeyword = keyword.trim().toLowerCase();
      if (selectedCategory != null && keyword.isNotEmpty) {
        filteredItems = itemsByCategory[selectedCategory!]!
            .where((item) => item.toLowerCase().contains(searchKeyword))
            .toList();
      } else {
        filteredItems = itemsByCategory[selectedCategory!]!;
      }
    });
  }

  // 물건 삭제 다이얼로그
  Future<void> _deleteItemDialog(List<String> items, int index) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('물건 삭제'),
          content: Text('이 물건을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                setState(() {
                  items.removeAt(index);
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryGrid() {
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
      itemCount: basicFoodsCategories.length,
      itemBuilder: (context, index) {
        String category = basicFoodsCategories[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selectedCategory == category) {
                selectedCategory = null;
              } else {
                selectedCategory = category;
                filteredItems = itemsByCategory[category] ?? []; // null 확인
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: selectedCategory == category
                  ? Colors.orange
                  : Colors.blueAccent,
              borderRadius: BorderRadius.circular(8.0),
            ), // 카테고리 버튼 크기 설정
            height: 60,
            margin: EdgeInsets.symmetric(vertical: 8.0),
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

// 카테고리별 아이템을 출력하는 그리드
  Widget _buildCategoryItemsGrid() {
    List<String> items = filteredItems.isNotEmpty
        ? filteredItems
        : itemsByCategory[selectedCategory!] ?? [];

    return GridView.builder(
      shrinkWrap: true, // GridView의 크기를 콘텐츠에 맞게 줄임
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 한 줄에 3칸
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1,
      ),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              height: 60, // 카
              child: Center(
                child: Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
          );
        } else {
          String currentItem = items[index];
          bool isSelected = selectedItems.contains(currentItem);
          bool isAddedToFridge = fridgeItems.contains(currentItem);
          // 기존 아이템 렌더링
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedItems.remove(currentItem);
                } else {
                  selectedItems.add(currentItem);
                }
              });
            },
            onDoubleTap: () {
              if (isSelected) {
                _addItemsToFridge();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isAddedToFridge
                    ? Colors.orange // 냉장고에 추가된 아이템은 오렌지색
                    : (isSelected ? Colors.orange : Colors.blueAccent),
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
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('냉장고 아이템 추가'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (selectedItems.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '검색어 입력',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (selectedCategory != null) {
                          _searchItems(value); // 검색어 입력 시 아이템 필터링
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed:
                        () {},
                    child: Text('검색'),
                  ),
                ],
              ),
            ),
            ],
            // 카테고리 그리드
            _buildCategoryGrid(),
        
            if (selectedCategory != null) ...[
              Divider(thickness: 2),
        
              // 아이템 그리드도 스크롤되게 함
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildCategoryItemsGrid(),
              ),
            ],
          ],
        ),
      ),
            bottomNavigationBar: selectedItems.isNotEmpty
                ? Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addItemsToFridge,
                      child: Text('냉장고에 추가'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        textStyle: TextStyle(fontSize: 20),

                      ),
                    ),
                  ),
                )
                  : null,
    );
  }
}

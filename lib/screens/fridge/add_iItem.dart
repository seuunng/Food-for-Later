import 'package:flutter/material.dart';
import 'package:food_for_later/screens/foods/add_item_to_category.dart';
import 'package:food_for_later/screens/fridge/fridge_item_details.dart';
import 'package:intl/intl.dart';

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
  bool isDeleteMode = false; // 삭제 모드 여부

  // 각 카테고리별 아이템 리스트 (예시 데이터)
  Map<String, List<String>> itemsByCategory = {
    '육류': ['소고기', '돼지고기', '닭고기'],
    '수산물': ['연어', '참치', '고등어'],
    '채소': ['양파', '당근', '감자'],
    '과일': [
      '사과', '바나나', '포도', '메론', '자몽', '블루베리', '라즈베리', '딸기', '체리', '오렌지', '골드키위', '참외', '수박', '감',
      '복숭아', '앵두', '자두', '배', '코코넛', '리치', '망고', '망고스틴', '아보카도', '복분자', '샤인머스캣', '용과', '라임', '레몬', '천도복숭아', '파인애플', '애플망고', '잭프릇', '람보탄', '아사히베리', ''
    ],
    '견과': ['아몬드', '호두', '캐슈넛'],
  };

  // 아이템 목록에서 중복된 값이 있는지 확인 후 제거
  void removeDuplicates() {
    itemsByCategory.forEach((category, items) {
      itemsByCategory[category] = items.toSet().toList();
    });
  }

  // initState 또는 빌드 직전에 중복 제거
  @override
  void initState() {
    super.initState();
    removeDuplicates(); // 중복 제거 함수 호출
  }

  // 현재 날짜
  DateTime currentDate = DateTime.now();

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
    // 화면 닫기 (AddItem 끄기)
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pop(context); // AddItem 화면을 종료
    });
  }

  // 검색 로직
  void _searchItems(String keyword) {
    List<String> tempFilteredItems = [];
    setState(() {
      searchKeyword = keyword.trim().toLowerCase();
      itemsByCategory.forEach((category, items) {
        tempFilteredItems.addAll(
          items.where((item) => item.toLowerCase().contains(searchKeyword)),
        );
      });
      filteredItems = tempFilteredItems;
    });
    }
    // 카테고리별 아이템을 출력하는 그리드
    Widget _buildFilteredItemsGrid() {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 한 줄에 4칸
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 1,
        ),
        itemCount: filteredItems.length + 1, // 입력된 검색어로 항목 추가
        itemBuilder: (context, index) {
          if (index == filteredItems.length) {
            // 마지막 그리드 항목에 "검색어로 새 항목 추가" 항목 표시
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (!selectedItems.contains(searchKeyword)) {
                    selectedItems.add(searchKeyword); // 검색어로 새로운 항목 추가
                  } else {
                    selectedItems.remove(searchKeyword); // 선택 취소
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectedItems.contains(searchKeyword) ? Colors.orange : Colors.cyan,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                height: 60,
                child: Center(
                  child: Text(
                    '$searchKeyword',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          } else {
            String currentItem = filteredItems[index];
            return GestureDetector(
              onTap: () {
                // 아이템 클릭 시 처리
                setState(() {
                  if (!selectedItems.contains(currentItem)) {
                    selectedItems.add(currentItem); // 아이템 선택
                  } else {
                    selectedItems.remove(currentItem); // 선택 취소
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: selectedItems.contains(currentItem) ? Colors.orange : Colors.blueAccent,
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
    // 삭제 모드에서 선택된 아이템들을 삭제하는 함수
    void _deleteSelectedItems() {
      setState(() {
        if (selectedCategory != null) {
          itemsByCategory[selectedCategory!]!.removeWhere(
                  (item) => selectedItems.contains(item));
        }
        selectedItems.clear(); // 선택된 아이템 목록 초기화
        isDeleteMode = false; // 삭제 모드 해제
      });
    }

    // 삭제 모드 여부를 토글하는 함수
    void _toggleDeleteMode() {
      setState(() {
        isDeleteMode = !isDeleteMode;
        if (!isDeleteMode) {
          selectedItems.clear(); // 삭제 모드 해제 시 선택 목록 초기화
        }
      });
    }
// 삭제 모드에서 선택된 아이템들을 삭제하기 전에 확인 다이얼로그를 띄우는 함수
    Future<void> _confirmDeleteItems() async {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('삭제 확인'),
            content: Text('선택된 아이템들을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop(false); // 취소 시 false 반환
                },
              ),
              TextButton(
                child: Text('삭제'),
                onPressed: () {
                  Navigator.of(context).pop(true); // 삭제 시 true 반환
                },
              ),
            ],
          );
        },
      );
      // 사용자가 삭제를 확인했을 때만 삭제 작업을 진행
      if (confirmDelete) {
        _deleteSelectedItems(); // 실제 삭제 로직 실행
      }
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
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == items.length) {
            //+아이콘 그리드 렌더링
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddItemToCategory(
                          categoryName: selectedCategory ?? '기타',),
                    fullscreenDialog: true, // 모달 다이얼로그처럼 보이게 설정
                  ),
                );
              },
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
                String currentItem = items[index];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FridgeItemDetails(
                          categoryName: selectedCategory ?? '기타',
                          categoryFoodsName: currentItem,
                          // 현재 아이템을 전달
                          expirationDays: 1,
                          // 예시 값
                          consumptionDays: 1,
                          // 예시 값
                          registrationDate: DateFormat('yyyy-MM-dd').format(
                              DateTime.now()), // 예시 값
                        ),
                    fullscreenDialog: true, // 모달 다이얼로그처럼 보이게 설정
                  ),
                );
              },
              onLongPress: () {
                setState(() {
                  _toggleDeleteMode();
                  selectedItems.add(currentItem); // 첫 번째 아이템 선택
                });
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
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

      return Scaffold(
        appBar: AppBar(
          title: Text('냉장고 아이템 추가'),
          actions: [
            if (isDeleteMode)
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: _confirmDeleteItems, // 선택된 아이템 삭제 전에 확인 다이얼로그
              ),
          ],
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
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: '검색어 입력',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _searchItems(value); // 검색어 입력 시 아이템 필터링
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _searchItems(searchKeyword); // 검색 버튼 클릭 시 검색어 필터링
                        },
                        child: Text('검색'),
                      ),
                    ],
                  ),
                ),
              ],
              // 카테고리 그리드
              if (filteredItems.isNotEmpty) ...[
              Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildFilteredItemsGrid(),
              ),
              ] else ...[
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
              onPressed: isDeleteMode ? _confirmDeleteItems : _addItemsToFridge,
              child: Text(isDeleteMode ? '삭제 하기' : '냉장고에 추가'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20),
                textStyle: TextStyle(fontSize: 20),
                // primary: isDeleteMode ? Colors.red : Colors.blue,
              ),
            ),
          ),
        )
            : null,

      );
    }
  }

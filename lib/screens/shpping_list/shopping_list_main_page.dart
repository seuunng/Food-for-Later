import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/foods_model.dart';
import 'package:food_for_later/models/shopping_category_model.dart';
import 'package:food_for_later/screens/fridge/add_item.dart';
import 'package:food_for_later/screens/fridge/fridge_main_page.dart';
import 'package:food_for_later/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingListMainPage extends StatefulWidget {
  @override
  _ShoppingListMainPageState createState() => _ShoppingListMainPageState();
}

class _ShoppingListMainPageState extends State<ShoppingListMainPage> {
  int _selectedIndex = 0;

  List<Widget> _pages = <Widget>[
    FridgeMainPage(), // 냉장고 페이지
    ShoppingListMainPage(), // 예시로 장보기 페이지
  ];

  List<String> fridgeName = [];
  String? selectedFridge = '';

  void _onItemTapped(int index) {
    if (index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  List<ShoppingCategory> _categories = [];
  Map<String, List<String>> itemLists = {};

  List<List<bool>> checkedItems =
  List.generate(9, (_) => [false, false, false]);
  List<List<bool>> strikeThroughItems =
  List.generate(9, (_) => [false, false, false]);

  bool showCheckBoxes = false;

  @override
  void initState() {
    super.initState();
    _loadItemsFromFirestore('현재 유저아이디');
    _loadCategoriesFromFirestore();
    _loadFridgeCategoriesFromFirestore('현재 유저아이디');
    _loadSelectedFridge();
  }

  void _loadItemsFromFirestore(String userId) async {
    try {
      final foodsSnapshot = await FirebaseFirestore.instance
          .collection('foods') // Foods 컬렉션에서 데이터 불러오기
          .get();

      final List<FoodsModel> foodsList = foodsSnapshot.docs
          .map((doc) => FoodsModel.fromFirestore(doc))
          .toList();

      final snapshot = await FirebaseFirestore.instance
          .collection('shopping_items')
          .where('userId', isEqualTo: userId) // 현재 유저의 아이템만 가져옴
          .get();

      List<Map<String, dynamic>> allItems = [];

      for (var doc in snapshot.docs) {
        final data = doc.data(); // 각 문서 출력

        final itemName = data['items']?.toString() ??
            'Unknown Item'; // items 필드 추출
        final isChecked = data['isChecked'] ?? false;

        final matchingFood = foodsList.firstWhere(
              (food) => food.foodsName == itemName,
          // itemName과 foodsName이 일치하는지 확인
          orElse: () =>
              FoodsModel(
                id: 'unknown',
                foodsName: itemName,
                defaultCategory: '기타',
                defaultFridgeCategory: '기타',
                shoppingListCategory: '기타',
                expirationDate: 0,
                shelfLife: 0,
              ),
        );

        allItems.add({
          'category': matchingFood.shoppingListCategory,
          // FoodsModel에서 가져온 카테고리 사용
          'itemName': itemName,
          'isChecked': isChecked,
          // 필드명이 맞는지 확인하고 기본 값 설정
        });
      }

      setState(() {
        itemLists = _groupItemsByCategory(allItems); // 카테고리별로 아이템을 그룹화
      });
    } catch (e) {
      print('Firestore에서 아이템 불러오는 중 오류 발생: $e');
    }
  }

  Map<String, List<String>> _groupItemsByCategory(
      List<Map<String, dynamic>> items) {
    Map<String, List<String>> groupedItems = {};

    for (var item in items) {
      final category = item['category']!; // FoodsModel에서 가져온 shoppingListCategory
      final itemName = item['itemName']!;

      if (groupedItems.containsKey(category)) {
        groupedItems[category]!.add(itemName);
      } else {
        groupedItems[category] = [itemName];
      }
    }
    return groupedItems;
  }


  Future<void> _loadCategoriesFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('shopping_categories')
        .get();

    final categories = snapshot.docs.map((doc) {
      return ShoppingCategory.fromFirestore(doc);
    }).toList();

    setState(() {
      _categories = categories;
    });
  }

  void _loadFridgeCategoriesFromFirestore(String userId) async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('fridges').get();
      List<String> fridgeList =
      snapshot.docs.map((doc) => doc['FridgeName'] as String).toList();

      setState(() {
        fridgeName = fridgeList; // 불러온 냉장고 목록을 상태에 저장
      });
    } catch (e) {
      print('Error loading fridge categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('냉장고 목록을 불러오는 데 실패했습니다.')),
      );
    }
  }

  void _loadSelectedFridge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFridge = prefs.getString('selectedFridge') ?? '기본 냉장고'; // 기본 값 설정
    });
  }

  // 취소선이 있는 아이템들은 자동으로 체크박스가 true
  void _selectStrikeThroughItems() {
    for (int section = 0; section < strikeThroughItems.length; section++) {
      for (int index = 0; index < strikeThroughItems[section].length; index++) {
        if (strikeThroughItems[section][index]) {
          checkedItems[section][index] = true;
        }
      }
    }
  }

// 냉장고로 이동 버튼이 나타나는 조건
  bool shouldShowMoveToFridgeButton() {
    for (var section in checkedItems) {
      if (section.contains(true)) return true;
    }
    return false;
  }

  Future<void> _addItemsToFridge() async {
    final fridgeId = selectedFridge != null && selectedFridge!.isNotEmpty
        ? selectedFridge
        : '기본 냉장고'; // 선택된 냉장고 ID 사용

    try {
      for (int sectionIndex = 0; sectionIndex < checkedItems.length; sectionIndex++) {
        final categoryItems = itemLists[_categories[sectionIndex].categoryName];
        if (categoryItems == null || categoryItems.isEmpty) {
          continue; // 카테고리에 아이템이 없으면 건너뜀
        }

        for (int index = 0; index < checkedItems[sectionIndex].length; index++) {
          if (checkedItems[sectionIndex][index]) {
            // 사용자가 선택한 아이템 이름
            String itemName = categoryItems[index];

            // FoodsModel에서 해당 itemName에 맞는 데이터를 찾기
            final matchingFood = await FirebaseFirestore.instance
                .collection('foods')
                .where('foodsName', isEqualTo: itemName)
                .get();

            if (matchingFood.docs.isEmpty) {
              print("일치하는 음식이 없습니다: $itemName");
              continue; // 일치하는 데이터가 없으면 건너뜀
            }

            final foodData = matchingFood.docs.first.data();
            final fridgeCategoryId = foodData['defaultFridgeCategory']; // fridgeCategoryId 설정
            final expirationDate = foodData['expirationDate'];
            final shelfLife = foodData['shelfLife'];

            // 냉장고에 아이템 추가
            await FirebaseFirestore.instance.collection('fridge_items').add({
              'items': itemName,
              'FridgeId': fridgeId, // 선택된 냉장고
              'fridgeCategoryId': fridgeCategoryId,
              // 'expirationDate': expirationDate,
              // 'shelfLife': shelfLife,
            });
          }
        }
      }

      // 성공적으로 추가한 후 체크된 아이템 초기화
      setState(() {
        checkedItems = List.generate(9, (_) => [false, false, false]); // 초기화
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('선택한 아이템이 냉장고에 추가되었습니다.')),
      );
    } catch (e) {
      print('아이템 추가 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이템 추가 중 오류가 발생했습니다.')),
      );
    }

    // 화면 닫기 (AddItem 끄기)
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        // mounted 상태를 확인하여 위젯이 아직 활성화된 상태일 때만 pop을 호출
        Navigator.pop(context); // AddItem 화면을 종료
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('장보기 목록'),
            SizedBox(width: 20),
            Expanded(
              child: DropdownButtonFormField<String>(
                value:
                fridgeName.contains(selectedFridge) ? selectedFridge : null,
                items: fridgeName.map((section) {
                  return DropdownMenuItem(
                    value: section,
                    child: Text(section),
                  );
                }).toList(), // 반복문을 통해 DropdownMenuItem 생성
                onChanged: (value) {
                  setState(() {
                    selectedFridge = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: '냉장고 선택',
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: _buildSections(), // 섹션 동적으로 생성
      ),

      // 물건 추가 버튼
      floatingActionButton: FloatingActionButton(
        heroTag: 'shopping_add_button',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddItem(
                    pageTitle: '장보기목록에 추가',
                    addButton: '장보기목록에 추가',
                    fridgeFieldIndex: '기본냉장고',
                    basicFoodsCategories: ['육류', '수산물', '채소', '과일', '견과'],
                    sourcePage: 'shoppingList',
                  ),
              fullscreenDialog: true, // 모달 다이얼로그처럼 보이게 설정
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: showCheckBoxes && shouldShowMoveToFridgeButton()
          ? Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                // BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: '냉장고'),
                onPressed: () {
                  _addItemsToFridge();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomeScreen()), // FridgeScreen은 냉장고로 이동할 화면
                  );
                },
                child: Text('냉장고로 이동'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: 15),
                  // 위아래 패딩을 조정하여 버튼 높이 축소
                  // backgroundColor: isDeleteMode ? Colors.red : Colors.blueAccent, // 삭제 모드일 때 빨간색, 아닐 때 파란색
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
                ),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {},
              child: Text('삭제'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    vertical: 15),
                // 위아래 패딩을 조정하여 버튼 높이 축소
                // backgroundColor: isDeleteMode ? Colors.red : Colors.blueAccent, // 삭제 모드일 때 빨간색, 아닐 때 파란색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게
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
          ],
        ),
      )
          : null,
    );
  }

  Widget _buildSections() {
    return Column(
      children: itemLists.keys.map((category) {
        int sectionIndex = itemLists.keys.toList().indexOf(category); // 각 카테고리의 인덱스를 가져옴
        return Column(
          children: [
            _buildSectionTitle(category), // 카테고리 타이틀
            _buildGrid(itemLists[category]!, sectionIndex), // 해당 카테고리의 아이템 렌더링
          ],
        );
      }).toList(),
    );
  }

  // 각 섹션의 타이틀 빌드
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10), // 제목과 수평선 사이 간격
          Expanded(
            child: Divider(
              thickness: 2, // 수평선 두께
              color: Colors.grey, // 수평선 색상
            ),
          ),
        ],
      ),
    );
  }

  // 물건을 추가할 수 있는 그리드
  Widget _buildGrid(List<String> items, int sectionIndex) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        childAspectRatio: 9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              strikeThroughItems[sectionIndex][index] =
              !strikeThroughItems[sectionIndex][index]; // 취소선 여부 설정
            });
          },
          onLongPress: () {
            setState(() {
              showCheckBoxes = true;
              _selectStrikeThroughItems(); // 취소선이 있는 아이템 체크박스 true
            });
          },
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                if (showCheckBoxes)
                  Checkbox(
                    value: checkedItems[sectionIndex][index], // 체크 상태
                    onChanged: (bool? value) {
                      setState(() {
                        checkedItems[sectionIndex][index] = value!; // 체크박스 업데이트
                      });
                    },
                  ),
                Expanded(
                  child: Text(
                    items[index],
                    style: TextStyle(
                      decoration: strikeThroughItems[sectionIndex][index]
                          ? TextDecoration.lineThrough
                          : TextDecoration.none, // 취소선 여부
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

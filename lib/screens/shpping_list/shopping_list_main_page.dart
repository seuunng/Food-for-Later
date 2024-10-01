import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/shopping_category.dart';
import 'package:food_for_later/screens/fridge/add_item.dart';
import 'package:food_for_later/screens/fridge/fridge_main_page.dart';
import 'package:food_for_later/screens/home_screen.dart';

class ShoppingListMainPage extends StatefulWidget {

  @override
  _ShoppingListMainPageState createState() => _ShoppingListMainPageState();
}

class _ShoppingListMainPageState extends State<ShoppingListMainPage> {
  int _selectedIndex = 0;

  // 각 페이지를 저장하는 리스트
  List<Widget> _pages = <Widget>[
    FridgeMainPage(), // 냉장고 페이지
    ShoppingListMainPage(), // 예시로 장보기 페이지
  ];

  void _onItemTapped(int index) {
    if (index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  List<ShoppingCategory> _categories = [];
  List<List<String>> itemLists = [];

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromFirestore();
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


  static const List<String> fridgeName = ['기본냉장고', '김치냉장고', '오빠네냉장고'];
  String? selectedFridge = '기본냉장고';

  List<List<bool>> checkedItems = List.generate(9, (_) => [false, false, false]);
  List<List<bool>> strikeThroughItems = List.generate(9, (_) => [false, false, false]);

  bool showCheckBoxes = false;

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
                value: selectedFridge,
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
              builder: (context) => AddItem(
                pageTitle: '장보기목록에 추가',
                addButton: '장보기목록에 추가',
                fridgeFieldIndex: '기본냉장고',
                basicFoodsCategories: [
                  '육류',
                  '수산물',
                  '채소',
                  '과일',
                  '견과'
                ],
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomeScreen()), // FridgeScreen은 냉장고로 이동할 화면
                        );
                      },
                      child: Text('냉장고로 이동'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15), // 위아래 패딩을 조정하여 버튼 높이 축소
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
        ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                    },
                    child: Text('삭제'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15), // 위아래 패딩을 조정하여 버튼 높이 축소
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
      children: List.generate(_categories.length, (index) {
        // itemLists의 길이가 충분한지 확인
        if (index >= itemLists.length) {
          itemLists.add([]); // 새로운 빈 리스트 추가
        }
        return Column(
          children: [
            _buildSectionTitle(_categories[index].categoryName), // 섹션 타이틀
            _buildGrid(itemLists[index], index), //
          ],
        );
      }),
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
      shrinkWrap: true, // GridView의 크기를 콘텐츠에 맞게 줄임
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // 한 줄에 5칸
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
              !strikeThroughItems[sectionIndex][index];
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
                        checkedItems[sectionIndex][index] = value!;
                      });
                    },
                  ),
                Expanded(
                  child: Text(
                    items[index],
                    style: TextStyle(
                      // 취소선 적용 여부
                      decoration: strikeThroughItems[sectionIndex][index]
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
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

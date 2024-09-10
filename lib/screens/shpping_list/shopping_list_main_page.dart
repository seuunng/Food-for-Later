import 'package:flutter/material.dart';
import 'package:food_for_later/screens/fridge/add_iItem.dart';

class ShoppingListMainPage extends StatefulWidget {
  @override
  _ShoppingListMainPageState createState() => _ShoppingListMainPageState();
}

class _ShoppingListMainPageState extends State<ShoppingListMainPage> {
  static const List<String> fridgeName = ['기본냉장고', '김치냉장고', '오빠네냉장고'];
  String? selectedFridge = '기본냉장고';

  static const List<String> storageSections = ['신선', '육류/수산', '공산품'];
  String? selectedSection;

  // List<List<String>> itemLists = [[], [], []];
  List<List<String>> itemLists = [
    ['사과', '바나나', '상추'], // 신선 섹션 아이템
    ['소고기', '연어', '닭가슴살'], // 육류/수산 섹션 아이템
    ['라면', '통조림', '밀가루'] // 공산품 섹션 아이템
  ];
  List<List<bool>> checkedItems = [
    [false, false, false], // 신선 섹션 체크박스 상태
    [false, false, false], // 육류/수산 섹션 체크박스 상태
    [false, false, false], // 공산품 섹션 체크박스 상태
  ];
  Widget _buildSections() {
    return Column(
      children: List.generate(storageSections.length, (index) {
        return Column(
          children: [
            _buildSectionTitle(storageSections[index]), // 섹션 타이틀
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
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
          },
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
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
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('장보기 목록'),
      ),
      body: SingleChildScrollView(
        child: _buildSections(), // 섹션 동적으로 생성
      ),

      // 물건 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddIitem(),
              fullscreenDialog: true, // 모달 다이얼로그처럼 보이게 설정
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

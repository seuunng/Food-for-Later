import 'package:flutter/material.dart';

class FridgeMainPage extends StatefulWidget {
  @override
  _FridgeMainPageState createState() => _FridgeMainPageState();

  }

  class _FridgeMainPageState extends State<FridgeMainPage> {
  List<String> fridgeItems = [];
  List<String> freezerItems = [];
  List<String> roomTempItems = [];

  // 물건을 추가할 수 있는 다이얼로그 호출
  Future<void> _addItemDialog() async {
    String? selectedSection;
    String newItem = '';

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새 물건 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSection,
                items: ['냉장칸', '냉동칸', '상온칸'].map((section) {
                  return DropdownMenuItem(
                    value: section,
                    child: Text(section),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSection = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: '구역 선택',
                ),
              ),
              TextField(
                onChanged: (value) {
                  newItem = value;
                },
                decoration: InputDecoration(hintText: '물건 이름을 입력하세요'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed: () {
                if (selectedSection != null && newItem.isNotEmpty) {
                  setState(() {
                    if (selectedSection == '냉장칸') {
                      fridgeItems.add(newItem);
                    } else if (selectedSection == '냉동칸') {
                      freezerItems.add(newItem);
                    } else if (selectedSection == '상온칸') {
                      roomTempItems.add(newItem);
                    }
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
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

  // 각 섹션의 타이틀 빌드
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 물건을 추가할 수 있는 그리드
  Widget _buildGrid(List<String> items) {
    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 한 줄에 5칸
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () {
              // 물건 삭제 다이얼로그
              _deleteItemDialog(items, index);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  items[index],
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('냉장고 관리'),
      ),
      body: Column(
        children: [
          // 냉장칸 섹션
          _buildSectionTitle('냉장칸'),
          _buildGrid(fridgeItems),
          Divider(),

          // 냉동칸 섹션
          _buildSectionTitle('냉동칸'),
          _buildGrid(freezerItems),
          Divider(),

          // 상온칸 섹션
          _buildSectionTitle('상온칸'),
          _buildGrid(roomTempItems),
        ],
      ),

      // 물건 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addItemDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
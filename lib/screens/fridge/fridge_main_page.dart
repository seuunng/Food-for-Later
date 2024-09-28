import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:food_for_later/screens/fridge/add_item.dart';
import 'package:food_for_later/screens/fridge/fridge_item_details.dart';

class FridgeMainPage extends StatefulWidget {
  @override
  _FridgeMainPageState createState() => _FridgeMainPageState();
}

class _FridgeMainPageState extends State<FridgeMainPage> {
  static const List<String> fridgeName = ['기본냉장고', '김치냉장고', '오빠네냉장고'];
  String? selectedFridge = '기본냉장고';

  static const List<String> storageSections = ['냉장', '냉동', '상온'];
  String? selectedSection;

  // List<List<String>> itemLists = [[], [], []];
  List<List<Map<String, int>>> itemLists = [
    [
      {'사과': 10}, // 예시: 10일 유통기한 남음
      {'깻잎': 5},
      {'상추': 2}
    ],
    [
      {'문어': 8},
      {'새우': 3},
      {'닭가슴살': 12}
    ],
    [
      {'라면': 15},
      {'통조림': 30},
      {'밀가루': 50}
    ]
  ];

  List<String> selectedItems = [];
  bool isDeleteMode = false;

  // 유통기한에 따른 색상 결정 함수
  Color _getBackgroundColor(int expirationDays) {
    if (expirationDays >= 7) {
      return Colors.lightGreen;
    } else if (expirationDays < 7 && expirationDays >= 3) {
      return Colors.yellow;
    } else {
      return Colors.deepOrangeAccent;
    }
  }

// 선택된 섹션에 해당하는 아이템을 가져오는 함수
  List<String> _getItemsForSelectedSection() {
    if (selectedSection != null) {
      int index = storageSections.indexOf(selectedSection!);
      if (index >= 0 && index < itemLists.length) {
        return itemLists[index].map((item) => item.keys.first).toList();
      }
    }
    return [];
  }

  // 현재 날짜
  DateTime currentDate = DateTime.now();

  // 삭제 모드에서 선택된 아이템들을 삭제하는 함수
  void _deleteSelectedItems() {
    setState(() {
      if (selectedSection != null) {
        List<String> items = _getItemsForSelectedSection();
        items.removeWhere((item) => selectedItems.contains(item));
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
      setState(() {
        isDeleteMode = false; // 삭제 작업 후 삭제 모드 해제
      });
    }
  }

  Widget _buildSections() {
    return Column(
      children: List.generate(storageSections.length, (index) {
        return Column(
          children: [
            _buildSectionTitle(storageSections[index]), // 섹션 타이틀
            _buildGrid(index), //
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
  Widget _buildGrid(int sectionIndex) {
    List<Map<String, int>> items = itemLists[sectionIndex];
    return DragTarget<String>(
      onAccept: (data) {
        setState(() {
          // 드래그된 항목을 새로운 섹션에 추가하고 원래 섹션에서 삭제
          itemLists[sectionIndex].add({data: 7});
          itemLists.forEach((section) =>
              section.removeWhere((item) => item.keys.first == data));
        });
      },
      builder: (context, candidateData, rejectedData) {
        return GridView.builder(
          shrinkWrap: true, // GridView의 크기를 콘텐츠에 맞게 줄임
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5, // 한 줄에 5칸
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            String currentItem = items[index].keys.first;
            int expirationDays = items[index][currentItem]!;
            bool isSelected = selectedItems.contains(currentItem);

            return Draggable<String>(
              data: currentItem,
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  width: 80,
                  height: 80,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[200],
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black26,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      currentItem,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              childWhenDragging: Container(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    currentItem,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              child: GestureDetector(
                onLongPress: () {
                  setState(() {
                    // 삭제 모드 전환 및 해제
                    if (isDeleteMode) {
                      isDeleteMode = false; // 삭제 모드 해제
                      selectedItems.clear(); // 선택된 아이템 목록 초기화
                    } else {
                      isDeleteMode = true; // 삭제 모드로 전환
                      selectedItems.add(currentItem);
                    }
                  });
                },
                onTap: () {
                  if (isDeleteMode) {
                    setState(() {
                      if (selectedItems.contains(currentItem)) {
                        selectedItems.remove(currentItem); // 선택 해제
                      } else {
                        selectedItems.add(currentItem); // 선택
                      }
                    });
                  }
                },
                onDoubleTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FridgeItemDetails(
                        categoryName: '과일', //동적데이터 필요
                        categoryFoodsName: currentItem,
                        expirationDays: expirationDays,
                        consumptionDays: 1,
                        registrationDate: DateFormat('yyyy-MM-dd')
                            .format(DateTime.now()), // 예시 값
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDeleteMode && isSelected
                        ? Colors.orange // 삭제 모드에서 선택된 항목은 주황색
                        : _getBackgroundColor(expirationDays),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      currentItem,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('냉장고 관리'),
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
        // actions: isDeleteMode
        //     ? [
        //         IconButton(
        //           icon: Icon(Icons.cancel_outlined),
        //           onPressed: () {
        //             setState(() {
        //               isDeleteMode = false; // 삭제 모드를 해제
        //               selectedItems.clear(); // 선택된 아이템 목록 초기화
        //             });
        //           },
        //         ),
        //       ]
        //     : [],
      ),
      body: SingleChildScrollView(
        child: _buildSections(), // 섹션 동적으로 생성
      ),

      // 물건 추가 버튼
      floatingActionButton: FloatingActionButton(
        heroTag: 'fridge_add_button',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItem(
                pageTitle: '냉장고에 추가',
                addButton: '냉장고에 추가',
                fridgeFieldIndex: '기본냉장고',
                basicFoodsCategories: ['육류', '수산물', '채소', '과일', '견과'],
              ),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: isDeleteMode
          ? Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmDeleteItems,
                  child: Text('삭제 하기'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
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
              ),
            )
          : null,
    );
  }
}

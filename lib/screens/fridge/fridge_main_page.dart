import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_for_later/models/fridge_category_model.dart';
import 'package:food_for_later/screens/fridge/fridge_category_search.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:food_for_later/screens/fridge/add_item.dart';
import 'package:food_for_later/screens/fridge/fridge_item_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FridgeMainPage extends StatefulWidget {

  @override
  _FridgeMainPageState createState() => _FridgeMainPageState();
}

class _FridgeMainPageState extends State<FridgeMainPage> {
  DateTime currentDate = DateTime.now();

  List<String> fridgeName = [];
  String? selectedFridge = '';

  List<FridgeCategory> storageSections = [];
  FridgeCategory? selectedSection;

  // List<List<String>> itemLists = [[], [], []];
  List<List<Map<String, int>>> itemLists = [
    [], [], []
  ];

  List<String> selectedItems = [];
  bool isDeleteMode = false;
  @override
  void initState() {
    super.initState();
    _loadFridgeCategoriesFromFirestore('현재 유저아이디');
    _loadSelectedFridge(); // 초기화 시 Firestore에서 데이터를 불러옴
    _loadCategoriesFromFirestore();
  }

  void _loadFridgeCategoriesFromFirestore(String fridgeId) async {
    final fridgeId = '1번 냉장고';
    try {
      // fridges 컬렉션에서 데이터를 불러옴
      final snapshot = await FirebaseFirestore.instance
          .collection('fridge_items')
          .where('FridgeId', isEqualTo: fridgeId)
          .get(); // 해당 유저 ID에 맞는 냉장고 데이터

      List<Map<String, dynamic>> items = snapshot.docs.map((doc) => doc.data()).toList();

      print("Items loaded from Firestore: $items");
      setState(() {
        if (storageSections.isEmpty) {
          print("storageSections is empty. Make sure it's loaded.");
          return;
        }

        // 아이템을 불러오고 fridgeCategoryId에 따라 storageSections에 아이템을 추가
        items.forEach((itemData) async {
          String fridgeCategoryId = itemData['fridgeCategoryId'] ?? '기타';
          String itemName = itemData['items'] ?? 'Unknown Item';

          print("Processing item: $itemName, Category: $fridgeCategoryId");

          // foods 컬렉션에서 해당 아이템 검색
          final foodsSnapshot = await FirebaseFirestore.instance
              .collection('foods')
              .where('foodsName', isEqualTo: itemName)
              .get();

          if (foodsSnapshot.docs.isNotEmpty) {
            final foodsData = foodsSnapshot.docs.first.data();
            int expirationDate = foodsData['expirationDate'] ?? 0;
            int shelfLife = foodsData['shelfLife'] ?? 0;

            print("Fetched from foods: expirationDate = $expirationDate, shelfLife = $shelfLife");

            // fridgeCategoryId가 storageSections의 categoryName과 일치하는지 확인
            int index = storageSections.indexWhere((section) => section.categoryName == fridgeCategoryId);

            if (index >= 0) {
              print("Adding item: $itemName to section: ${storageSections[index].categoryName}");
              // 해당 카테고리에 아이템 추가
              itemLists[index].add({
                itemName: expirationDate,  // expirationDate를 추가
              });
            } else {
              print("Category not found: $fridgeCategoryId");
            }
          } else {
            print("Item not found in foods collection: $itemName");
          }
        });

        print("Updated itemLists: $itemLists");
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

  Future<void> _loadCategoriesFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('fridge_categories')
        .get();

    final categories = snapshot.docs.map((doc) {
      return FridgeCategory.fromFirestore(doc);
    }).toList();
    setState(() {
      storageSections = categories;
    });
  }

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
      int index = storageSections.indexWhere((section) => section.id == selectedSection!.id);
      if (index >= 0 && index < itemLists.length) {
        return itemLists[index].map((item) => item.keys.first).toList();
      }
    }
    return [];
  }


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
                value: fridgeName.contains(selectedFridge) ? selectedFridge : null,
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
                sourcePage: 'fridge',
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
  Widget _buildSections() {
    return Column(
      children: List.generate(storageSections.length, (index) {
        return Column(
          children: [
            _buildSectionTitle(storageSections[index].categoryName), // 섹션 타이틀
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
      onAccept: (data) async {
        setState(() {
          // 드래그된 항목을 새로운 섹션에 추가하고 원래 섹션에서 삭제
          itemLists[sectionIndex].add({data: 7});
          itemLists.forEach((section) =>
              section.removeWhere((item) => item.keys.first == data));
        });

        // 드래그한 항목의 fridgeCategoryId 업데이트
        String newFridgeCategoryId = storageSections[sectionIndex].categoryName;

        try {
          // Firestore에서 해당 아이템을 찾아 fridgeCategoryId를 업데이트
          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('fridge_items')
              .where('items', isEqualTo: data)
              .get();

          if (snapshot.docs.isNotEmpty) {
            // 해당 아이템의 문서 ID 가져오기
            String docId = snapshot.docs.first.id;

            // fridgeCategoryId 업데이트
            await FirebaseFirestore.instance
                .collection('fridge_items')
                .doc(docId)
                .update({'fridgeCategoryId': newFridgeCategoryId});

            print("fridgeCategoryId updated for $data to $newFridgeCategoryId");
          } else {
            print("Item not found in fridge_items collection: $data");
          }
        } catch (e) {
          print("Error updating fridgeCategoryId: $e");
        }
      },
      builder: (context, candidateData, rejectedData) {
        return GridView.builder(
          shrinkWrap: true,
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
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_for_later/components/floating_add_button.dart';
import 'package:food_for_later/components/navbar_button.dart';
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

  List<List<Map<String, dynamic>>> itemLists = [[], [], []];

  List<String> selectedItems = [];
  bool isDeletedMode = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedFridge();
    _loadCategoriesFromFirestore();
    _loadFridgeNameFromFirestore();
    _loadCategoriesAndFridgeData();
    setState(() {
      isDeletedMode = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFridgeCategoriesFromFirestore(selectedFridge ?? '기본 냉장고');
  }

  void _loadCategoriesAndFridgeData() async {
    await _loadCategoriesFromFirestore();
    if (storageSections.isNotEmpty) {
      _loadFridgeCategoriesFromFirestore(selectedFridge ?? '기본 냉장고');
    }
  }

  void refreshFridgeItems() {
    _loadFridgeCategoriesFromFirestore(selectedFridge); // 아이템 목록 새로고침
  }

  Future<void> _loadFridgeCategoriesFromFirestore(String? fridgeId) async {
    final fridgeId = selectedFridge;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('fridge_items')
          .where('FridgeId', isEqualTo: fridgeId)
          .get(); // 해당 유저 ID에 맞는 냉장고 데이터

      List<Map<String, dynamic>> items =
          snapshot.docs.map((doc) => doc.data()).toList();

      if (storageSections.isEmpty) {
        print("storageSections is empty. Make sure it's loaded.");
        return;
      }
      setState(() {
        itemLists =
            List.generate(storageSections.length, (_) => [], growable: true);
      });

      for (var itemData in items) {
        String fridgeCategoryId = itemData['fridgeCategoryId'] ?? '기타';
        String itemName = itemData['items'] ?? 'Unknown Item';

        try {
          final foodsSnapshot = await FirebaseFirestore.instance
              .collection('foods')
              .where('foodsName', isEqualTo: itemName)
              .get();

          if (foodsSnapshot.docs.isNotEmpty) {
            final foodsData = foodsSnapshot.docs.first.data();
            int expirationDate = foodsData['expirationDate'] ?? 0;
            int shelfLife = foodsData['shelfLife'] ?? 0;

            // fridgeCategoryId가 storageSections의 categoryName과 일치하는지 확인
            int index = storageSections.indexWhere(
                (section) => section.categoryName == fridgeCategoryId);

            if (index >= 0) {
              setState(() {
                itemLists[index].add({
                  itemName: expirationDate,
                });
              });
            } else {
              print("Category not found: $fridgeCategoryId");
            }
          } else {
            print("Item not found in foods collection: $itemName");
          }
        } catch (e) {
          print('Error fetching or processing food data for $itemName: $e');
        }
      }
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

  //냉장고 내부 구분
  Future<void> _loadCategoriesFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('fridge_categories').get();

    final categories = snapshot.docs.map((doc) {
      return FridgeCategory.fromFirestore(doc);
    }).toList();

    setState(() {
      storageSections = categories;
    });
  }

  Future<void> _loadFridgeNameFromFirestore() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('fridges').get();

    List<String> fridgeList = snapshot.docs.map((doc) {
      return (doc['FridgeName'] ?? 'Unknown Fridge')
          as String; // 명시적으로 String 타입으로 변환
    }).toList();

    setState(() {
      fridgeName = fridgeList; // fridgeName 리스트에 저장
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
//   List<String> _getItemsForSelectedSection() {
//     if (selectedSection != null) {
//       int index = storageSections
//           .indexWhere((section) => section.id == selectedSection!.id);
//       if (index >= 0 && index < itemLists.length) {
//         return itemLists[index].map((item) => item.keys.first).toList();
//       }
//     }
//     return [];
//   }

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
                _deleteSelectedItems();
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
        isDeletedMode = false; // 삭제 작업 후 삭제 모드 해제
      });
    }
  }

  // 삭제 모드에서 선택된 아이템들을 삭제하는 함수
  void _deleteSelectedItems() async {
    if (selectedItems == null || selectedItems.isEmpty) {
      print("선택된 아이템이 없습니다. 삭제할 수 없습니다.");
      return;
    }

    List<String> itemsToDelete = List.from(selectedItems);

    try {
      for (String item in itemsToDelete) {
        final snapshot = await FirebaseFirestore.instance
            .collection('fridge_items')
            .where('items', isEqualTo: item) // 선택된 아이템 이름과 일치하는 문서 검색
            .where('FridgeId', isEqualTo: selectedFridge) // 선택된 냉장고 ID 필터
            .get();

        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            await FirebaseFirestore.instance
                .collection('fridge_items')
                .doc(doc.id) // 문서 ID로 삭제
                .delete();
          }
        }
      }
      // 로컬 상태에서도 삭제
      setState(() {
        for (String item in itemsToDelete) {
          for (var section in itemLists) {
            section.removeWhere((map) => map.keys.first == item);
          }
        }
        selectedItems.clear(); // 선택된 아이템 목록 초기화
        isDeletedMode = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('선택된 아이템이 삭제되었습니다.')),
      );
    } catch (e) {
      print('Error deleting items from Firestore: $e');
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
                    _loadFridgeCategoriesFromFirestore(selectedFridge!);
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
      floatingActionButton: !isDeletedMode?
      FloatingAddButton(
        heroTag: 'fridge_add_button',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddItem(
                    pageTitle: '냉장고에 추가',
                    addButton: '냉장고에 추가',
                    sourcePage: 'fridge',
                    onItemAdded: () {
                      _loadFridgeCategoriesFromFirestore(
                          selectedFridge ?? '기본 냉장고');
                    },
                  ),
            ),
          );
          setState(() {
            _loadFridgeCategoriesFromFirestore(selectedFridge ?? '기본 냉장고');
          });
        },
      ): null,

      bottomNavigationBar: isDeletedMode
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: NavbarButton(
                  buttonTitle: '삭제 하기',
                  onPressed: _confirmDeleteItems,
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
            _buildDragTargetSection(index), // 드래그 타겟으로 각 섹션 구성
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

  Widget _buildGridForSection(
      List<Map<String, dynamic>> items, int sectionIndex) {
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
        String currentItem = items[index].keys.first; // 아이템 이름
        int expirationDays = items[index].values.first;
        bool isSelected = selectedItems.contains(currentItem);

        return Draggable<String>(
          data: currentItem, // 드래그할 데이터 (현재 아이템 이름)
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
                  ),
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
                if (isDeletedMode) {
                  isDeletedMode = false;
                  selectedItems.clear();
                } else {
                  isDeletedMode = true;
                  selectedItems.add(currentItem);
                }
              });
            },
            onTap: () {
              if (isDeletedMode) {
                setState(() {
                  if (selectedItems.contains(currentItem)) {
                    selectedItems.remove(currentItem);
                  } else {
                    selectedItems.add(currentItem);
                  }
                });
              }
            },
            onDoubleTap: () async {
              try {
                // Firestore에서 현재 선택된 아이템의 정보를 불러옵니다.
                final foodsSnapshot = await FirebaseFirestore.instance
                    .collection('foods')
                    .where('foodsName',
                        isEqualTo: currentItem) // 현재 아이템과 일치하는지 확인
                    .get();

                if (foodsSnapshot.docs.isNotEmpty) {
                  final foodsData = foodsSnapshot.docs.first.data();

                  // Firestore에서 불러온 데이터를 동적으로 할당
                  String defaultCategory = foodsData['defaultCategory'] ?? '기타';
                  String defaultFridgeCategory =
                      foodsData['defaultFridgeCategory'] ?? '기타';
                  String shoppingListCategory =
                      foodsData['shoppingListCategory'] ?? '기타';
                  int expirationDays = foodsData['expirationDate'] ?? 0;
                  int shelfLife = foodsData['shelfLife'] ?? 0;

                  // FridgeItemDetails로 동적으로 데이터를 전달
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FridgeItemDetails(
                        foodsName: currentItem, // 아이템 이름
                        foodsCategory: defaultCategory, // 동적 카테고리
                        fridgeCategory: defaultFridgeCategory, // 냉장고 섹션
                        shoppingListCategory:
                            shoppingListCategory, // 쇼핑 리스트 카테고리
                        expirationDays: expirationDays, // 유통기한
                        consumptionDays: shelfLife, // 소비기한
                        registrationDate:
                            DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      ),
                    ),
                  );
                } else {
                  print("Item not found in foods collection: $currentItem");
                }
              } catch (e) {
                print('Error fetching food details: $e');
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: isDeletedMode && isSelected
                    ? Colors.orange
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
  }

  Widget _buildDragTargetSection(int sectionIndex) {
    return DragTarget<String>(
      onAccept: (draggedItem) async {
        setState(() {
          // 해당 섹션으로 아이템 이동
          if (!itemLists[sectionIndex]
              .any((map) => map['items'] == draggedItem)) {
            itemLists[sectionIndex].add(
                {'items': draggedItem, 'expirationDate': 7}); // 예시로 7일 유통기한 설정
          }

          // 기존 섹션에서 아이템 제거
          for (var section in itemLists) {
            section.removeWhere((item) => item['items'] == draggedItem);
          }
        });

        // Firestore에서 fridgeCategoryId 업데이트
        String newFridgeCategoryId = storageSections[sectionIndex].categoryName;

        try {
          // Firestore에서 해당 아이템을 찾아 fridgeCategoryId 업데이트
          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('fridge_items')
              .where('items', isEqualTo: draggedItem)
              .get();

          if (snapshot.docs.isNotEmpty) {
            String docId = snapshot.docs.first.id;

            // fridgeCategoryId 업데이트
            await FirebaseFirestore.instance
                .collection('fridge_items')
                .doc(docId)
                .update({'fridgeCategoryId': newFridgeCategoryId});

            refreshFridgeItems();
          }
        } catch (e) {
          print('Error updating fridgeCategoryId: $e');
        }
      },
      builder: (context, candidateData, rejectedData) {
        return _buildGridForSection(
            itemLists[sectionIndex], sectionIndex); // 섹션 내 그리드 빌드
      },
    );
  }

  Widget _buildItem(String itemName, int expirationDays) {
    return Container(
      decoration: BoxDecoration(
        color: _getBackgroundColor(expirationDays),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Text(
          itemName,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // 물건을 추가할 수 있는 그리드
  Widget _buildGrid(int sectionIndex) {
    if (sectionIndex >= itemLists.length) {
      return Container(); // 인덱스가 범위를 벗어나면 빈 컨테이너 반환
    }

    List<Map<String, dynamic>> items = itemLists[sectionIndex] ?? [];
    return DragTarget<String>(
      onAccept: (data) async {
        setState(() {
          if (!itemLists[sectionIndex].any((map) => map.keys.first == data)) {
            itemLists[sectionIndex].add({data: 7});
          }

          for (var section in itemLists) {
            section.removeWhere((item) => item.keys.first == data);
          }
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
            String currentItem = items[index].keys.first ?? 'Unknown Item';
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
                    if (isDeletedMode) {
                      isDeletedMode = false; // 삭제 모드 해제
                      selectedItems.clear(); // 선택된 아이템 목록 초기화
                    } else {
                      isDeletedMode = true; // 삭제 모드로 전환
                      selectedItems.add(currentItem);
                    }
                  });
                },
                onTap: () {
                  if (isDeletedMode) {
                    setState(() {
                      if (selectedItems.contains(currentItem)) {
                        selectedItems.remove(currentItem); // 선택 해제
                      } else {
                        selectedItems.add(currentItem); // 선택
                      }
                    });
                  }
                },
                onDoubleTap: () async {
                  try {
                    // Firestore에서 현재 선택된 아이템의 정보를 불러옵니다.
                    final foodsSnapshot = await FirebaseFirestore.instance
                        .collection('foods')
                        .where('foodsName',
                            isEqualTo: currentItem) // 현재 아이템과 일치하는지 확인
                        .get();

                    if (foodsSnapshot.docs.isNotEmpty) {
                      final foodsData = foodsSnapshot.docs.first.data();

                      // Firestore에서 불러온 데이터를 동적으로 할당
                      String defaultCategory =
                          foodsData['defaultCategory'] ?? '기타';
                      String defaultFridgeCategory =
                          foodsData['defaultFridgeCategory'] ?? '기타';
                      String shoppingListCategory =
                          foodsData['shoppingListCategory'] ?? '기타';
                      int expirationDays = foodsData['expirationDate'] ?? 0;
                      int shelfLife = foodsData['shelfLife'] ?? 0;

                      // FridgeItemDetails로 동적으로 데이터를 전달
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FridgeItemDetails(
                            foodsName: currentItem, // 아이템 이름
                            foodsCategory: defaultCategory, // 동적 카테고리
                            fridgeCategory: defaultFridgeCategory, // 냉장고 섹션
                            shoppingListCategory:
                                shoppingListCategory, // 쇼핑 리스트 카테고리
                            expirationDays: expirationDays, // 유통기한
                            consumptionDays: shelfLife, // 소비기한
                            registrationDate:
                                DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          ),
                        ),
                      );
                    } else {
                      print("Item not found in foods collection: $currentItem");
                    }
                  } catch (e) {
                    print('Error fetching food details: $e');
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDeletedMode && isSelected
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/components/floating_add_button.dart';
import 'package:food_for_later/components/navbar_button.dart';
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

  List<String> fridgeName = [];
  String? selectedFridge = '';

  List<ShoppingCategory> _categories = [];
  Map<String, List<String>> itemLists = {};

  Map<String, List<bool>> checkedItems = {};
  Map<String, List<bool>> strikeThroughItems = {};

  bool showCheckBoxes = false;
  Map<String, List<String>> groupedItems = {};

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

        final itemName =
            data['items']?.toString() ?? 'Unknown Item'; // items 필드 추출
        final isChecked = data['isChecked'] ?? false;

        final matchingFood = foodsList.firstWhere(
          (food) => food.foodsName == itemName,
          // itemName과 foodsName이 일치하는지 확인
          orElse: () => FoodsModel(
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
          'itemName': itemName,
          'isChecked': isChecked,
        });
      }

      setState(() {
        itemLists = _groupItemsByCategory(allItems); // 카테고리별로 아이템을 그룹화
        // isChecked가 true인 항목을 처리
        allItems.forEach((item) {
          final category = item['category'];
          final itemName = item['itemName'];
          final isChecked = item['isChecked'];

          // checkedItems와 strikeThroughItems를 초기화하고 isChecked가 true이면 값을 설정
          if (itemLists.containsKey(category)) {
            final itemIndex = itemLists[category]?.indexOf(itemName) ?? -1;
            if (itemIndex != -1) {
              checkedItems[category] ??= List<bool>.filled(itemLists[category]!.length, false, growable: true); // 수정!
              strikeThroughItems[category] ??= List<bool>.filled(itemLists[category]!.length, false, growable: true); // 수정!

              if (isChecked) {
                checkedItems[category]![itemIndex] = true;
                strikeThroughItems[category]![itemIndex] = true; // 취소선도 설정
              }
            }
          }
        });
      });

    } catch (e) {
      print('Firestore에서 아이템 불러오는 중 오류 발생: $e');
    }
  }

  Map<String, List<String>> _groupItemsByCategory(
      List<Map<String, dynamic>> items) {

    for (var item in items) {
      final category =
          item['category']!; // FoodsModel에서 가져온 shoppingListCategory
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
  void _selectStrikeThroughItems() async {
    for (var category in itemLists.keys) {
      int itemCount = itemLists[category]?.length ?? 0;

      checkedItems[category] ??= List<bool>.filled(itemCount, false, growable: true); // 수정!
      strikeThroughItems[category] ??= List<bool>.filled(itemCount, false, growable: true); // 수정!

      for (int index = 0; index < itemCount; index++) {
        if (strikeThroughItems[category]![index]) {
          checkedItems[category]![index] = true;

          String itemName = itemLists[category]?[index] ?? '';

          if (itemName.isNotEmpty) {
            try {
              // Firestore에서 해당 아이템을 찾아 'isChecked' 값을 true로 업데이트
              final snapshot = await FirebaseFirestore.instance
                  .collection('shopping_items')
                  .where('items', isEqualTo: itemName) // 아이템 이름으로 문서 찾기
                  .get();

              if (snapshot.docs.isNotEmpty) {
                for (var doc in snapshot.docs) {
                  await FirebaseFirestore.instance
                      .collection('shopping_items')
                      .doc(doc.id) // 문서 ID를 사용하여 업데이트
                      .update({
                    'isChecked': true, // 'isChecked' 필드를 true로 업데이트
                  });
                }
              } else {
                print('Item not found in shopping_items: $itemName');
              }
            } catch (e) {
              print('Error updating isChecked for $itemName: $e');
            }
          }
        }
      }
    }
    setState(() {});
  }

// 냉장고로 이동 버튼이 나타나는 조건
  bool shouldShowMoveToFridgeButton() {
    for (var category in checkedItems.keys) {
      if (checkedItems[category]!.contains(true)) return true;
    }
    return false;
  }

  Future<void> _addItemsToFridge() async {
    final fridgeId = selectedFridge != null && selectedFridge!.isNotEmpty
        ? selectedFridge
        : '기본 냉장고';
    try {
      for (var category in checkedItems.keys) {
        List<String> categoryItems = List<String>.from(itemLists[category]!);

        if (categoryItems.isEmpty) {
          continue;
        }

        List<int> itemsToRemove = [];

        for (int index = 0; index < checkedItems[category]!.length; index++) {
            if (checkedItems[category]![index]) {
              String itemName = categoryItems[index];

              // FoodsModel에서 해당 itemName에 맞는 데이터를 찾기
            final matchingFood = await FirebaseFirestore.instance
                .collection('foods')
                .where('foodsName', isEqualTo: itemName)
                .get();

            if (matchingFood.docs.isEmpty) {
              print("일치하는 음식이 없습니다: $itemName");
              continue;
            }

            final foodData = matchingFood.docs.first.data();
            final fridgeCategoryId =
                foodData['defaultFridgeCategory']; // fridgeCategoryId 설정

              final existingItem = await FirebaseFirestore.instance
                  .collection('fridge_items')
                  .where('items', isEqualTo: itemName.trim().toLowerCase())
                  // .where('FridgeId', isEqualTo: fridgeId.trim())
                  .get();

              if (existingItem.docs.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"$itemName"이(가) 이미 냉장고에 존재합니다.')),
                );
                // 중복되어도 장보기 목록에서만 삭제
              } else {
                // 냉장고에 아이템 추가 (중복되지 않은 경우)
                await FirebaseFirestore.instance.collection('fridge_items').add({
                  'items': itemName,
                  'FridgeId': fridgeId, // 선택된 냉장고
                  'fridgeCategoryId': fridgeCategoryId,
                  // 'expirationDate': expirationDate,
                  // 'shelfLife': shelfLife,
                });
              }

              final snapshot = await FirebaseFirestore.instance
                  .collection('shopping_items')
                  .where('items', isEqualTo: itemName)
                  .where('userId', isEqualTo: '현재 유저아이디') // 유저 ID로 필터
                  .get();

              if (snapshot.docs.isNotEmpty) {
                for (var doc in snapshot.docs) {
                  await FirebaseFirestore.instance
                      .collection('shopping_items')
                      .doc(doc.id)
                      .delete();
                }
              }
              itemsToRemove.add(index);
          }
        }
        setState(() {
          for (int i = itemsToRemove.length - 1; i >= 0; i--) {
            int removeIndex = itemsToRemove[i];
            categoryItems.removeAt(removeIndex);
            checkedItems[category]!.removeAt(removeIndex);
            strikeThroughItems[category]!.removeAt(removeIndex);
          }
          itemLists[category] = categoryItems;
        });
      }
    } catch (e) {
      print('아이템 추가 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이템 추가 중 오류가 발생했습니다.')),
      );
    }
  }

  void _updateIsCheckedInFirestore(String itemName, bool isChecked) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('shopping_items')
          .where('items', isEqualTo: itemName) // 아이템 이름으로 문서 찾기
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          await FirebaseFirestore.instance
              .collection('shopping_items')
              .doc(doc.id) // 문서 ID를 사용하여 업데이트
              .update({
            'isChecked': isChecked, // isChecked 필드를 업데이트
          });
        }
      } else {
        print('Item not found in shopping_items: $itemName');
      }
    } catch (e) {
      print('Error updating isChecked for $itemName: $e');
    }
  }

  Future<void> _deleteSelectedItems() async {
    try {
      for (var category in checkedItems.keys) {
        List<String> categoryItems = List<String>.from(itemLists[category]!);

        List<int> itemsToRemove = [];

        for (int index = 0; index < checkedItems[category]!.length; index++) {
          if (checkedItems[category]![index]) {
            String itemName = categoryItems[index];

            final snapshot = await FirebaseFirestore.instance
                .collection('shopping_items')
                .where('items', isEqualTo: itemName)
                .where('userId', isEqualTo: '현재 유저아이디') // 유저 ID로 필터
                .get();

            if (snapshot.docs.isNotEmpty) {
              for (var doc in snapshot.docs) {
                await FirebaseFirestore.instance
                    .collection('shopping_items')
                    .doc(doc.id) // 문서 ID를 사용하여 삭제
                    .delete();
              }
            }

            itemsToRemove.add(index);
          }
        }

        setState(() {
          // 역순으로 삭제하여 인덱스 오류 방지
          for (int i = itemsToRemove.length - 1; i >= 0; i--) {
            int removeIndex = itemsToRemove[i];
            categoryItems.removeAt(removeIndex); // 아이템 삭제
            checkedItems[category]!.removeAt(removeIndex); // 체크 상태 삭제
            strikeThroughItems[category]!.removeAt(removeIndex); // 취소선 삭제
          }
          itemLists[category] = categoryItems;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이템이 삭제되었습니다.')),
      );
    } catch (e) {
      print('아이템 삭제 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이템 삭제 중 오류가 발생했습니다.')),
      );
    }
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
      floatingActionButton: !showCheckBoxes || !shouldShowMoveToFridgeButton() ?
      FloatingAddButton(
        heroTag: 'shopping_add_button',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItem(
                pageTitle: '장보기 목록에 추가',
                addButton: '장보기 목록에 추가',
                sourcePage: 'shoppingList',
                onItemAdded: () {
                },
              ),
              fullscreenDialog: true, // 모달 다이얼로그처럼 보이게 설정
            ),
          );
          setState(() {
            itemLists.clear(); // 중복 방지를 위해 아이템 리스트 초기화
            checkedItems.clear(); // 체크박스 상태 초기화
            strikeThroughItems.clear(); // 취소선 상태 초기화
            _loadItemsFromFirestore('현재 유저아이디');
          });
        },
      ):null,
      bottomNavigationBar: showCheckBoxes && shouldShowMoveToFridgeButton()
          ? Container(
              color: Colors.transparent,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: NavbarButton(
                      buttonTitle: '냉장고로 이동',
                      onPressed: () {
                        _addItemsToFridge();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  HomeScreen()),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  NavbarButton(
                    buttonTitle: '삭제',
                    onPressed: () async {
                      await _deleteSelectedItems();
                    },
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
        return Column(
          children: [
            _buildSectionTitle(category), // 카테고리 타이틀
            _buildGrid(itemLists[category]!, category), // 해당 카테고리의 아이템 렌더링
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
  Widget _buildGrid(List<String> items, String category) {
    if (items.isEmpty) {
      return Container();
    }
    if (!checkedItems.containsKey(category) || checkedItems[category]!.length != items.length) {
      checkedItems[category] = List<bool>.filled(items.length, false, growable: true); // 수정!
    }
    if (!strikeThroughItems.containsKey(category) || strikeThroughItems[category]!.length != items.length) {
      strikeThroughItems[category] = List<bool>.filled(items.length, false, growable: true); // 수정!
    }

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
              strikeThroughItems[category]![index] = !strikeThroughItems[category]![index];
              checkedItems[category]![index] = strikeThroughItems[category]![index]; // 취소선 상태에 따라 체크박스 업데이트

              // Firestore에서 isChecked 값 업데이트
              String itemName = items[index];
              _updateIsCheckedInFirestore(itemName, strikeThroughItems[category]![index]);
            });
          },
          onLongPress: () {
            setState(() {
              if (showCheckBoxes) {
                // 체크박스가 보이는 상태일 때 다시 누르면 체크박스 숨김
                showCheckBoxes = false;

                // 모든 checkedItems를 false로 초기화
                checkedItems.forEach((category, checkedList) {
                  for (int i = 0; i < checkedList.length; i++) {
                    checkedList[i] = false;
                  }
                });

                // 냉장고로 이동 버튼을 감추기 위해 UI를 갱신
              } else {
                // 체크박스를 다시 보이게 할 때는 취소선이 있는 아이템 체크박스 true로 설정
                showCheckBoxes = true;
                _selectStrikeThroughItems(); // 취소선이 있는 아이템 체크박스 true
              }
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
                    value: checkedItems[category]![index], // 체크 상태
                    onChanged: (bool? value) {
                      setState(() {
                        checkedItems[category]![index] = value!; // 체크박스 업데이트
                      });
                    },
                  ),
                Expanded(
                  child: Text(
                    items[index],
                    style: TextStyle(
                      decoration: strikeThroughItems[category]![index]
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

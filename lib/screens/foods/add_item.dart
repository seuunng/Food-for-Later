import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/components/basic_elevated_button.dart';
import 'package:food_for_later/components/navbar_button.dart';
import 'package:food_for_later/models/default_food_model.dart';
import 'package:food_for_later/models/foods_model.dart';
import 'package:food_for_later/models/preferred_food_model.dart';
import 'package:food_for_later/screens/foods/add_item_to_category.dart';
import 'package:food_for_later/screens/fridge/fridge_item_details.dart';
import 'package:intl/intl.dart';

class AddItem extends StatefulWidget {
  final String pageTitle;
  final String addButton;
  // final String fridgeFieldIndex;
  final String sourcePage;
  final Function onItemAdded;

  AddItem({
    required this.pageTitle,
    required this.addButton,
    // required this.fridgeFieldIndex,
    required this.sourcePage,
    required this.onItemAdded,
  });

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  DateTime currentDate = DateTime.now();

  static const List<String> storageSections = [];

  List<List<Map<String, int>>> itemLists = [[], [], []];
  List<String> fridgeItems = [];
  List<String> selectedItems = [];
  List<FoodsModel> filteredItems = [];

  String? selectedCategory;
  String? selectedSection;
  String searchKeyword = '';
  String? selectedItem;
  int expirationDays = 7;
  bool isDeleteMode = false; // 삭제 모드 여부
  List<String> deletedItems = [];

  // 유통기한을 위한 컨트롤러 및 함수 추가
  TextEditingController expirationDaysController = TextEditingController();

  Map<String, List<FoodsModel>> itemsByCategory = {};
  Map<String, List<PreferredFoodModel>> itemsByPreferredCategory = {};
  List<FoodsModel> items = [];
  Set<String> deletedItemNames = {};

  // initState 또는 빌드 직전에 중복 제거
  @override
  void initState() {
    super.initState();
    // removeDuplicates(); // 중복 제거 함수 호출
    if (widget.sourcePage == 'preferred_foods_category') {
      _loadPreferredFoodsCategoriesFromFirestore();
    } else {
      _loadCategoriesFromFirestore();
    }
    _loadDeletedItems();
  }

  void _navigateToAddItemPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemToCategory(
          categoryName: selectedCategory ?? '기타',
        ),
        fullscreenDialog: true, // 모달 다이얼로그처럼 보이게 설정
      ),
    );

    if (result == true) {
      _loadCategoriesFromFirestore();
    }
  }

  void _loadCategoriesFromFirestore() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('foods').get();
      final categories = snapshot.docs.map((doc) {
        return FoodsModel.fromFirestore(doc);
      }).toList();

      setState(() {
        itemsByCategory = {};

        for (var category in categories) {
          // 삭제된 아이템이면 건너뛰기
          if (widget.sourcePage != 'update_foods_category') {
            if (deletedItemNames.contains(category.foodsName)) {
              continue;
            }
          }

          // 기존 카테고리 리스트가 있으면 추가, 없으면 새 리스트 생성
          if (itemsByCategory.containsKey(category.defaultCategory)) {
            itemsByCategory[category.defaultCategory]!
                .add(category); // 이미 있는 리스트에 추가
          } else {
            itemsByCategory[category.defaultCategory] = [
              category
            ]; // 새로운 리스트 생성
          }
        }
      });
    } catch (e) {
      print('카테고리 데이터를 불러오는 데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 데이터를 불러오는 데 실패했습니다.')),
      );
    }
  }

  void _loadDeletedItems() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('deleted_foods')
          .where('isDeleted', isEqualTo: true)
          .get();

      setState(() {
        deletedItemNames = snapshot.docs
            .map((doc) => doc.data()['itemName'] as String)
            .toSet();
      });

      print('Deleted items: $deletedItemNames');
    } catch (e) {
      print('Failed to load deleted items: $e');
    }
  }

  void _loadPreferredFoodsCategoriesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('preferred_foods_categories')
          .get();
      final categories = snapshot.docs.map((doc) {
        return PreferredFoodModel.fromFirestore(doc);
      }).toList();

      setState(() {
        itemsByPreferredCategory = {};

        for (var categoryModel in categories) {
          // 각 categoryModel의 category 필드(Map<String, List<String>>)에서 키를 추출
          categoryModel.category.forEach((categoryName, itemList) {
            // 해당 카테고리 이름으로 itemsByPreferredCategory에 데이터를 추가
            if (itemsByPreferredCategory.containsKey(categoryName)) {
              // 이미 있는 리스트에 categoryModel을 추가
              itemsByPreferredCategory[categoryName]!.add(categoryModel);
            } else {
              // 새로운 리스트 생성 후 categoryModel 추가
              itemsByPreferredCategory[categoryName] = [categoryModel];
            }
          });
        }
      });
    } catch (e) {
      print('카테고리 데이터를 불러오는 데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 데이터를 불러오는 데 실패했습니다.')),
      );
    }
  }

  // 물건 추가 다이얼로그
  Future<void> _addItemsToFridge() async {
    final fridgeId = '1번 냉장고'; // 여기에 실제 유저 ID를 추가하세요

    try {
      for (String itemName in selectedItems) {
        // FoodsModel에서 해당 itemName에 맞는 데이터를 찾기
        final matchingFood = itemsByCategory.values.expand((x) => x).firstWhere(
              (food) => food.foodsName == itemName, // itemName과 일치하는지 확인
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

        final fridgeCategoryId = matchingFood.defaultFridgeCategory;

        final existingItemSnapshot = await FirebaseFirestore.instance
            .collection('fridge_items')
            .where('items', isEqualTo: itemName.trim().toLowerCase()) // 이름 일치
            .where('FridgeId', isEqualTo: fridgeId) // 냉장고 일치
            .get();

        if (existingItemSnapshot.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('fridge_items').add({
            'items': itemName,
            'FridgeId': fridgeId, // Firestore에 저장할 필드
            'fridgeCategoryId': fridgeCategoryId,
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$itemName 아이템이 이미 냉장고에 있습니다.')),
          );
        }
      }

      setState(() {
        selectedItems.clear();
      });

      widget.onItemAdded();

      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context, true); // Navigator.pop의 중복 실행 방지
      }
    } catch (e) {
      print('아이템 추가 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이템 추가 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<void> _addItemsToShoppingList() async {
    final userId = '현재 유저아이디'; // 여기에 실제 유저 ID를 추가하세요

    try {
      for (String itemName in selectedItems) {
        final existingItemSnapshot = await FirebaseFirestore.instance
            .collection('shopping_items')
            .where('items',
                isEqualTo: itemName.trim().toLowerCase()) // 공백 및 대소문자 제거
            .where('userId', isEqualTo: userId)
            .get();

        if (existingItemSnapshot.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('shopping_items').add({
            'items': itemName,
            'userId': userId,
            'isChecked': false, // 장바구니에 추가된 아이템은 기본적으로 체크되지 않음
          });
        } else {
          print("이미 냉장고에 존재하는 아이템: $itemName");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미 냉장고에 존재하는 아이템입니다.')),
          );
        }
      }

      // 아이템 추가 후 상태 초기화
      setState(() {
        selectedItems.clear();
      });
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

  // 검색 로직
  void _searchItems(String keyword) {
    List<FoodsModel> tempFilteredItems = [];
    setState(() {
      searchKeyword = keyword.trim().toLowerCase();

      if (widget.sourcePage == 'preferred_foods_category') {
        itemsByPreferredCategory.forEach((category, categoryModels) {
          for (var categoryModel in categoryModels) {
            categoryModel.category.forEach((_, items) {
              tempFilteredItems.addAll(
                items
                    .where((item) => item.toLowerCase().contains(searchKeyword))
                    .map((item) => FoodsModel(
                          id: 'unknown', // 임시 ID 값 설정
                          foodsName: item, // item은 String이므로 foodsName에 할당
                          defaultCategory: category, // 카테고리명 할당
                          defaultFridgeCategory: '기타', // 기타 필드 값은 임시로 설정
                          shoppingListCategory: '기타',
                          expirationDate: 0,
                          shelfLife: 0,
                        )),
              );
            });
          }
        });
      } else {}
      itemsByCategory.forEach((category, items) {
        tempFilteredItems.addAll(
          items.where(
              (item) => item.foodsName.toLowerCase().contains(searchKeyword)),
        );
      });
      filteredItems = tempFilteredItems;
    });
  }


  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageTitle),
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
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 10.0),
                        ),
                        onChanged: (value) {
                          _searchItems(value); // 검색어 입력 시 아이템 필터링
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    BasicElevatedButton(
                      onPressed: () {
                        _searchItems(searchKeyword); // 검색 버튼 클릭 시 검색어 필터링
                      },
                      iconTitle: Icons.search,
                      buttonTitle: '검색',
                    ),
                  ],
                ),
              ),
            ],
            if (filteredItems.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildFilteredItemsGrid(),
              ),
            ] else ...[
              if (widget.sourcePage == 'preferred_foods_category')
                _buildPreferredCategoryGrid()
              else
                _buildCategoryGrid(),
              if (selectedCategory != null) ...[
                Divider(thickness: 2),
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
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: NavbarButton(
                  buttonTitle: widget.addButton,
                  onPressed: () {
                    if (widget.sourcePage == 'shoppingList') {
                      _addItemsToShoppingList(); // 장바구니에 아이템 추가
                    } else if (widget.sourcePage == 'fridge') {
                      _addItemsToFridge(); // 냉장고에 아이템 추가
                    }
                  },
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildFilteredItemsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1,
      ),
      itemCount: filteredItems.length +
          (filteredItems.contains(searchKeyword) ? 0 : 1),
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
                color: selectedItems.contains(searchKeyword)
                    ? Colors.orange
                    : Colors.cyan,
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
          FoodsModel currentItem = filteredItems[index];
          String itemName = currentItem.foodsName; // 여기서 itemName 추출
          //키워드 검색 결과 그리드 렌더링
          return GestureDetector(
            onTap: () {
              setState(() {
                if (!selectedItems.contains(itemName)) {
                  selectedItems.add(itemName); // 아이템 선택
                } else {
                  selectedItems.remove(itemName); // 선택 취소
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: selectedItems.contains(itemName)
                    ? Colors.orange
                    : Colors.blueAccent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              height: 60,
              child: Center(
                child: AutoSizeText(
                  itemName,
                  style: TextStyle(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  minFontSize: 6, // 최소 글자 크기 설정
                  maxFontSize: 16, // 최대 글자 크기 설정
                ),
              ),
            ),
          );
        }
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
        itemCount: itemsByCategory.keys.length,
        itemBuilder: (context, index) {
          String category = itemsByCategory.keys.elementAt(index);
          // 아이템 그리드 마지막에 +아이콘 그리드 렌더링
          return GestureDetector(
            onTap: () {
              setState(() {
                if (selectedCategory == category) {
                  selectedCategory = null;
                } else {
                  selectedCategory = category;
                  // filteredItems = widget.itemsByCategory[category] ?? []; // null 확인
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
              // margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
          child: AutoSizeText(
                  category,
                  style: TextStyle(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  minFontSize: 6, // 최소 글자 크기 설정
                  maxFontSize: 16, // 최대 글자 크기 설정
                ),
              ),
            ),
          );
        });
  }

  Widget _buildPreferredCategoryGrid() {
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
      itemCount: itemsByPreferredCategory.keys.length,
      itemBuilder: (context, index) {
        String category = itemsByPreferredCategory.keys.elementAt(index);
        // 카테고리 그리드 렌더링
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selectedCategory == category) {
                selectedCategory = null;
              } else {
                selectedCategory = category;
                // filteredItems = widget.itemsByCategory[category] ?? []; // null 확인
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
            // margin: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: AutoSizeText(
                category,
                style: TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                minFontSize: 6, // 최소 글자 크기 설정
                maxFontSize: 16, // 최대 글자 크기 설정
              ),
            ),
          ),
        );
      },
    );
  }

  // 카테고리별 아이템을 출력하는 그리드
  Widget _buildCategoryItemsGrid() {
    List<FoodsModel> items = [];

    if (selectedCategory != null) {
      if (widget.sourcePage == 'preferred_foods_category') {
        // preferred_foods_category에서 데이터를 로드
        if (itemsByPreferredCategory.containsKey(selectedCategory!)) {
          items = itemsByPreferredCategory[selectedCategory!]!
              .expand(
                  (categoryModel) => categoryModel.category[selectedCategory]!)
              .map((itemName) => FoodsModel(
                    id: 'unknown',
                    foodsName: itemName,
                    defaultCategory: selectedCategory!,
                    defaultFridgeCategory: '기타',
                    shoppingListCategory: '기타',
                    expirationDate: 0,
                    shelfLife: 0,
                  ))
              .toList();
        }
      } else if (itemsByCategory.containsKey(selectedCategory!)) {
        items = itemsByCategory[selectedCategory!] ?? [];
      }
    }

    return GridView.builder(
      shrinkWrap: true,
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
          //아이템 그리드 마지막에 +아이콘 그리드 렌더링
          return GestureDetector(
            onTap: () {
              _navigateToAddItemPage();
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
          FoodsModel currentItem = items[index];
          String itemName = currentItem.foodsName;
          bool isSelected = selectedItems.contains(itemName);
          bool isDeleted = deletedItemNames.contains(itemName);
          // 기존 아이템 그리드 렌더링
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  selectedItems.remove(itemName);
                } else {
                  selectedItems.add(itemName);
                }
              });
            },
            onDoubleTap: () async {
              try {
                final foodsSnapshot = await FirebaseFirestore.instance
                    .collection('foods')
                    .where('foodsName',
                        isEqualTo: currentItem) // 현재 아이템과 일치하는지 확인
                    .get();

                if (foodsSnapshot.docs.isNotEmpty) {
                  final foodsData = foodsSnapshot.docs.first.data();

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
                        foodsName: currentItem.foodsName, // 아이템 이름
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
            onLongPress: widget.sourcePage == 'update_foods_category'
                ? () async {
                    if (isDeleted) {
                      // 이미 삭제된 아이템이면 Firestore에서 삭제
                      await FirebaseFirestore.instance
                          .collection('deleted_foods')
                          .where('itemName', isEqualTo: currentItem.foodsName)
                          .get()
                          .then((snapshot) {
                        for (var doc in snapshot.docs) {
                          doc.reference.delete(); // 문서 삭제
                        }
                      });

                      setState(() {
                        isDeleted = false; // 삭제 상태 해제
                        deletedItemNames
                            .remove(currentItem.foodsName); // 삭제 목록에서 제거
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('${currentItem.foodsName} 아이템이 복원되었습니다.')),
                      );
                    } else {
                      await FirebaseFirestore.instance
                          .collection('deleted_foods')
                          .doc(currentItem.id)
                          .set({'isDeleted': true, 'itemName': itemName});

                      setState(() {
                        isDeleted = true;
                        deletedItemNames.add(itemName);
                      });
                    }
                  }
                : null,
            child: Container(
              decoration: BoxDecoration(
                color: isDeleted
                    ? Colors.grey // 삭제된 아이템은 회색
                    : (isSelected ? Colors.orange : Colors.blueAccent),
                borderRadius: BorderRadius.circular(8.0),
              ),
              height: 60,
              child: Center(
                child: AutoSizeText(
                  itemName,
                  style: TextStyle(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  minFontSize: 6, // 최소 글자 크기 설정
                  maxFontSize: 16, // 최대 글자 크기 설정
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

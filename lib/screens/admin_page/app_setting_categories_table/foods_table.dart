import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/default_food_model.dart';
import 'package:food_for_later/models/shopping_category.dart';

enum SortState { none, ascending, descending }

class FoodsTable extends StatefulWidget {
  @override
  _FoodsTableState createState() => _FoodsTableState();
}

class _FoodsTableState extends State<FoodsTable> {
  // 각 열에 대한 정렬 상태를 관리하는 리스트
  List<Map<String, dynamic>> columns = [
    {'name': '선택', 'state': SortState.none},
    {'name': '연번', 'state': SortState.none},
    {'name': '카테고리', 'state': SortState.none},
    {'name': '식품명', 'state': SortState.none},
    {'name': '냉장고카테고리', 'state': SortState.none},
    {'name': '소비기한', 'state': SortState.none},
    {'name': '유통기한', 'state': SortState.none},
    {'name': '장보기카테고리', 'state': SortState.none},
    {'name': '변동', 'state': SortState.none}
  ];

  bool isEditing = false;
  int? selectedFoodIndex; // 수정할 아이템의 인덱스
  List<Map<String, dynamic>> userData = [];
  List<int> selectedRows = [];

  // 드롭다운 선택 항목들
  final List<String> categoryOptions = [];
  final List<String> fridgeCategoryOptions = ['냉장', '냉동', '실온'];
  final List<String> shoppingCategoryOptions = [];
  List<Map<String, dynamic>> _tableData = [];

  // 선택된 값들을 저장할 변수들
  String? _selectedCategory;
  String? _selectedFridgeCategory;
  String? _selectedShoppingListCategory;

// 추가할 때 사용할 입력 필드 컨트롤러들
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _shelfLifeController = TextEditingController();
  final TextEditingController _expirationDateController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoodsData();
    _loadDefaultFoodsCategories();
    _loadShoppingCategories();
    // addSampleFood();
  }
  // 샘플데이터 입력 메서드
  // Future<void> addFoodToFirestore(DefaultFoodModel foodModel) async {
  //   final collectionRef = FirebaseFirestore.instance.collection('default_foods_categories');
  //
  //   try {
  //     // Firestore에 데이터 추가
  //     await collectionRef.add(foodModel.toFirestore());
  //
  //     print('데이터가 성공적으로 추가되었습니다.');
  //   } catch (e) {
  //     print('Firestore에 데이터를 추가하는 중 오류가 발생했습니다: $e');
  //   }
  // }
  // void addSampleFood() async {
  //   DefaultFoodModel newFood = DefaultFoodModel(
  //     id: '1', // Firestore가 자동으로 id를 생성하기 때문에 굳이 넣을 필요는 없음.
  //     categories: '육류', // 대분류 카테고리
  //     itemsByCategory: [
  //       {
  //         'itemId': '1',
  //         'itemName': '삼겹살',
  //         'defaultFridgeCategory': '냉장',
  //         'shoppingListCategory': '육류/수산',
  //         'shelfLife': 5,
  //         'expirationDate': 10,
  //         'isDisabled': false,
  //       },
  //     ],
  //   );
  //   await addFoodToFirestore(newFood);
  // }

  Future<void> _loadFoodsData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('default_foods_categories')
        .get();
    List<Map<String, dynamic>> foods = [];

    snapshot.docs.forEach((doc) {
      final food = DefaultFoodModel.fromFirestore(doc);

      // 카테고리 내 모든 itemsByCategory의 아이템을 순회하면서 각 아이템을 추가
      for (var item in food.itemsByCategory) {
        foods.add({
          '연번': foods.length + 1, // 연번은 자동으로 증가하도록 설정
          '카테고리': food.categories, // Firestore의 카테고리를 사용
          'itemId': item['itemId'], // itemId 추가
          '식품명': item['itemName'], // 각 itemName을 출력
          '냉장고카테고리': item['defaultFridgeCategory'],
          '장보기카테고리': item['shoppingListCategory'],
          '소비기한': item['shelfLife'],
          '유통기한': item['expirationDate'],
        });
      }
    });
    setState(() {
      userData = foods;
    });
  }

  Future<void> _loadDefaultFoodsCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('default_foods_categories')
        .get();

    final categories =
        snapshot.docs.map((doc) => doc.data()['categories'] as String).toList();

    setState(() {
      // 변환된 데이터를 userData에 할당
      categoryOptions.clear();
      categoryOptions.addAll(categories);
    });
  }

  Future<void> _loadShoppingCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('shopping_categories')
        .get();
    final categories = snapshot.docs.map((doc) {
      return ShoppingCategory.fromFirestore(doc);
    }).toList();

    setState(() {
      shoppingCategoryOptions.clear();
      shoppingCategoryOptions
          .addAll(categories.map((category) => category.categoryName).toList());
    });
  }



  // 사용자 데이터를 추가하는 함수
  void _addFood(String categoryName, Map<String, dynamic> newItem) async {
    final collectionRef =
        FirebaseFirestore.instance.collection('default_foods_categories');

    try {
      final querySnapshot = await collectionRef
          .where('categories', isEqualTo: categoryName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;
        final existingData =
            DefaultFoodModel.fromFirestore(querySnapshot.docs.first);

        final newId = existingData.itemsByCategory.length + 1;
        newItem['itemId'] = newId.toString(); // 아이디를 연번으로 부여

        final updatedItems =
            List<Map<String, dynamic>>.from(existingData.itemsByCategory)
              ..add(newItem);

        await docRef.update({
          'itemsByCategory': updatedItems,
        });

      } else {
        newItem['itemId'] = '1';
        await collectionRef.add({
          'categories': categoryName,
          'itemsByCategory': [newItem],
        });

      }
    } catch (e) {
      print('Firestore에 저장하는 중 오류가 발생했습니다: $e');
    }
  }

  void _editFood(int index) {
    final selectedFood = userData[index];

    setState(() {
      _foodNameController.text = selectedFood['식품명'] ?? '';
      _selectedCategory = selectedFood['카테고리'] ?? '';
      _selectedFridgeCategory = selectedFood['냉장고카테고리'] ?? '';
      _selectedShoppingListCategory = selectedFood['장보기카테고리'] ?? '';
      _shelfLifeController.text = selectedFood['소비기한'].toString();
      _expirationDateController.text = selectedFood['유통기한'].toString();
    });
    isEditing = true;
    selectedFoodIndex = index;
  }

  // 파이어베이스에 데이터를 수정해서 업데이트하는 함수
  void _updateFood(int index) async {
    final selectedFood = userData[index];

    final foodName =_foodNameController.text;
    final category = _selectedCategory ?? selectedFood['카테고리'];
    final fridgeCategory = _selectedFridgeCategory ?? selectedFood['냉장고카테고리'];
    final shoppingListCategory = _selectedShoppingListCategory ?? selectedFood['장보기카테고리'];
    final shelfLife = int.tryParse(_shelfLifeController.text) ?? selectedFood['소비기한'];
    final expirationDate = int.tryParse(_expirationDateController.text) ?? selectedFood['유통기한'];

    try {
      final _db = await FirebaseFirestore.instance
          .collection('default_foods_categories')
          .where('categories', isEqualTo: selectedFood['카테고리'])
          .get();

      if (_db.docs.isNotEmpty) {
        final docRef = _db.docs.first.reference;
        final existingData = DefaultFoodModel.fromFirestore(_db.docs.first);

        List<Map<String, dynamic>> updatedItems = List<Map<String, dynamic>>.from(existingData.itemsByCategory);

        // 수정하려는 itemId와 일치하는 아이템을 찾아 수정
        int itemIndex = updatedItems.indexWhere((item) => item['itemId'] == selectedFood['itemId']);

        if (itemIndex != -1) {
          updatedItems[itemIndex] = {
            'itemId': selectedFood['itemId'],
            'itemName': foodName,
            'defaultFridgeCategory': fridgeCategory,
            'shoppingListCategory': shoppingListCategory,
            'shelfLife': shelfLife,
            'expirationDate': expirationDate,
          };

          // Firestore에 업데이트된 itemsByCategory를 저장
          await docRef.update({
            'categories': category,
            'itemsByCategory': updatedItems,
          });

          // 로컬 데이터 업데이트
          setState(() {
            userData[index] = {
              ...selectedFood,
              'categories': category,
              'itemName': foodName,
              'defaultFridgeCategory': fridgeCategory,
              'shoppingListCategory': shoppingListCategory,
              'shelfLife': shelfLife,
              'expirationDate': expirationDate,
            };
          });
        } else {
          print('아이템을 찾을 수 없습니다.');
        }
      }
    } catch (e) {
      print('Firestore에 데이터를 업데이트하는 중 오류가 발생했습니다: $e');
    }
  }

  // 체크박스를 사용해 선택한 행 삭제
  void _deleteSelectedRows(int index) async {
    final selectedFood = userData[index];

    bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제 확인'),
          content: Text('선택한 항목을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 취소 선택 시 false 반환
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 확인 선택 시 true 반환
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('default_foods_categories')
            .where('categories', isEqualTo: selectedFood['카테고리'])
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final docRef = querySnapshot.docs.first.reference;
          final existingData = DefaultFoodModel.fromFirestore(querySnapshot.docs.first);

          // 기존 itemsByCategory 배열에서 해당 itemId를 가진 아이템을 제거
          List<Map<String, dynamic>> updatedItems = List<Map<String, dynamic>>.from(existingData.itemsByCategory)
            ..removeWhere((item) => item['itemId'] == selectedFood['itemId']);

          // Firestore에 업데이트된 itemsByCategory 배열을 다시 저장
          await docRef.update({
            'itemsByCategory': updatedItems,
          });

          setState(() {
            userData.removeAt(index); // 로컬 상태에서도 데이터 삭제
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('선택한 항목이 삭제되었습니다.')),
          );
        }
      } catch (e) {
        print('Error deleting food from Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 중 오류가 발생했습니다.')),
        );
      }
    }
  }

  void _sortBy(String columnName, SortState currentState) {
    setState(() {
      // 열의 정렬 상태를 업데이트
      for (var column in columns) {
        if (column['name'] == columnName) {
          column['state'] = currentState == SortState.none
              ? SortState.ascending
              : (currentState == SortState.ascending
                  ? SortState.descending
                  : SortState.none);
        } else {
          column['state'] = SortState.none;
        }
      }

      // 정렬 수행
      if (currentState == SortState.none) {
        // 정렬 없으면 원래 데이터 순서 유지
        userData.sort((a, b) => a['연번'].compareTo(b['연번']));
      } else {
        userData.sort((a, b) {
          int result;
          result = a[columnName].compareTo(b[columnName]);
          return currentState == SortState.ascending ? result : -result;
        });
      }
    });
  }

  void _refreshTable() async {
    await _loadFoodsData();
    setState(() {}); // 화면을 새로고침
  }

  void _clearFields() {
    _foodNameController.clear();
    _shelfLifeController.clear();
    _expirationDateController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedFridgeCategory = null;
      _selectedShoppingListCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          // 제목이 있는 행
          Table(
            border: TableBorder(
              horizontalInside: BorderSide(width: 1, color: Colors.black),
            ),
            columnWidths: const {
              0: FixedColumnWidth(40), // 체크박스 열 크기
              1: FixedColumnWidth(60),
              2: FixedColumnWidth(120),
              3: FixedColumnWidth(100),
              4: FixedColumnWidth(120),
              5: FixedColumnWidth(80),
              6: FixedColumnWidth(80),
              7: FixedColumnWidth(180),
              8: FixedColumnWidth(80),
            },
            children: [
              TableRow(
                children: columns.map((column) {
                  return TableCell(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 1, color: Colors.black), // 셀 아래 테두리 추가
                        ),
                      ),
                      child: column['name'] == '선택' || column['name'] == '변동'
                          ? Center(
                              child: Text(column['name']),
                            )
                          : GestureDetector(
                              onTap: () =>
                                  _sortBy(column['name'], column['state']),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(column['name']),
                                    Icon(
                                      column['state'] == SortState.ascending
                                          ? Icons.arrow_upward
                                          : column['state'] ==
                                                  SortState.descending
                                              ? Icons.arrow_downward
                                              : Icons.sort,
                                      size: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 입력 필드들이 들어간 행
          Table(
            border: TableBorder(
              horizontalInside: BorderSide(width: 1, color: Colors.black),
            ),
            columnWidths: const {
              0: FixedColumnWidth(40),
              1: FixedColumnWidth(60),
              2: FixedColumnWidth(120),
              3: FixedColumnWidth(100),
              4: FixedColumnWidth(120),
              5: FixedColumnWidth(80),
              6: FixedColumnWidth(80),
              7: FixedColumnWidth(180),
              8: FixedColumnWidth(80),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        width: 1, color: Colors.black), // 셀 아래 테두리 추가
                  ),
                ),
                children: [
                  TableCell(child: SizedBox.shrink()),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Center(child: Text('no'))),
                  TableCell(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      items: categoryOptions.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        hintText: '카테고리',
                        hintStyle: TextStyle(
                          fontSize: 12, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        contentPadding: EdgeInsets.only(bottom: 13, left: 20),
                      ),
                      style: TextStyle(
                        fontSize: 14, // 선택된 값의 글씨 크기
                        color: Colors.black, // 선택된 값의 색상
                      ),
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  TableCell(
                    child: TextField(
                      controller: _foodNameController,
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '식품명',
                        hintStyle: TextStyle(
                          fontSize: 14, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        suffixIcon: _foodNameController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _foodNameController.clear(); // 입력 필드 내용 삭제
                                  });
                                },
                              )
                            : null, // 내용이 없을 때는 버튼을 표시하지 않음
                      ),
                      onChanged: (value) {
                        setState(() {}); // 입력 내용이 바뀔 때 상태 업데이트
                      },
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: DropdownButtonFormField<String>(
                      value: _selectedFridgeCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedFridgeCategory = value;
                        });
                      },
                      items: fridgeCategoryOptions.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        hintText: '냉장고 선택',
                        hintStyle: TextStyle(
                          fontSize: 14, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        contentPadding: EdgeInsets.only(bottom: 13, left: 20),
                      ),
                      style: TextStyle(
                        fontSize: 14, // 선택된 값의 글씨 크기
                        color: Colors.black, // 선택된 값의 색상
                      ),
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  TableCell(
                    child: TextField(
                      controller: _shelfLifeController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '소비기한',
                        hintStyle: TextStyle(
                          fontSize: 14, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        suffixIcon: _shelfLifeController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _shelfLifeController.clear(); // 입력 필드 내용 삭제
                                  });
                                },
                              )
                            : null, // 내용이 없을 때는 버튼을 표시하지 않음
                      ),
                      onChanged: (value) {
                        setState(() {}); // 입력 내용이 바뀔 때 상태 업데이트
                      },
                    ),
                  ),
                  TableCell(
                    child: TextField(
                      controller: _expirationDateController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '유통기한',
                        hintStyle: TextStyle(
                          fontSize: 14, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        suffixIcon: _expirationDateController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _expirationDateController.clear(); // 입력 필드 내용 삭제
                                  });
                                },
                              )
                            : null, // 내용이 없을 때는 버튼을 표시하지 않음
                      ),
                      onChanged: (value) {
                        setState(() {}); // 입력 내용이 바뀔 때 상태 업데이트
                      },
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: DropdownButtonFormField<String>(
                      value: _selectedShoppingListCategory,
                      onChanged: (value) {
                        setState(() {
                          _selectedShoppingListCategory = value;
                        });
                      },
                      items: shoppingCategoryOptions.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        hintText: '장보기 선택',
                        hintStyle: TextStyle(
                          fontSize: 14, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        contentPadding: EdgeInsets.only(bottom: 13, left: 20),
                      ),
                      style: TextStyle(
                        fontSize: 14, // 선택된 값의 글씨 크기
                        color: Colors.black, // 선택된 값의 색상
                      ),
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: SizedBox(
                      width: 60, // 버튼의 너비를 설정
                      height: 30, // 버튼의 높이를 설정
                      child: ElevatedButton(
                        onPressed: () {
                          if (isEditing) {

                            if (selectedFoodIndex != null) {
                              _updateFood(selectedFoodIndex!);
                            }
                          } else {
                            Map<String, dynamic> newItem = {
                              'itemName': _foodNameController.text,
                              'defaultFridgeCategory': _selectedFridgeCategory,
                              'shoppingListCategory':
                                  _selectedShoppingListCategory,
                              'shelfLife': int.tryParse(
                                  _shelfLifeController.text), // 소비기한 추가
                              'expirationDate': int.tryParse(
                                  _expirationDateController.text), // 유통기한 추가
                              'isDisabled': false, // 기본값 설정
                            };
                            // _selectedCategory가 null일 수 있으므로 체크 후 호출
                            if (_selectedCategory != null) {
                              _addFood(_selectedCategory!, newItem);
                            } else {
                              print('카테고리를 선택하세요.');
                            }
                          }

                          setState(() {
                            _clearFields();
                            _refreshTable();
                          });
                        },
                        child: Text('추가'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 데이터가 추가되는 테이블
          Table(
            border: TableBorder(
              horizontalInside: BorderSide(width: 1, color: Colors.black),
            ),
            columnWidths: const {
              0: FixedColumnWidth(40),
              1: FixedColumnWidth(60),
              2: FixedColumnWidth(120),
              3: FixedColumnWidth(100),
              4: FixedColumnWidth(120),
              5: FixedColumnWidth(80),
              6: FixedColumnWidth(80),
              7: FixedColumnWidth(180),
              8: FixedColumnWidth(80),
            },
            children: userData.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> row = entry.value;
              return TableRow(
                children: [
                  TableCell(
                    child: Checkbox(
                      value: selectedRows.contains(index),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedRows.add(index);
                          } else {
                            selectedRows.remove(index);
                          }
                        });
                      },
                    ),
                  ),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Container(
                          height: 40,
                          child: Center(child: Text(row['연번'].toString())))),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Center(child: Text(row['카테고리']))),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Center(child: Text(row['식품명']))),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Center(child: Text(row['냉장고카테고리']))),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Center(child: Text(row['소비기한'].toString()))),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Center(child: Text(row['유통기한'].toString()))),
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Center(child: Text(row['장보기카테고리']))),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: SizedBox(
                      width: 60, // 버튼의 너비를 설정
                      height: 30, // 버튼의 높이를 설정
                      child: ElevatedButton(
                        onPressed: () => _editFood(row['연번'] - 1), // 수정 버튼 클릭 시
                        child: Text('수정'),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          // 선택한 행 삭제 버튼
          ElevatedButton(
            onPressed: selectedRows.isNotEmpty
                ? () {
                    // 선택된 모든 행 삭제
                    for (int index in selectedRows) {
                      _deleteSelectedRows(index);
                    }
                  }
                : null,
            child: Text('선택한 항목 삭제'),
          ),
        ],
      ),
    );
  }
}

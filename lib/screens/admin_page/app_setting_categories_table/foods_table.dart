import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/default_foodModel.dart';

enum SortState { none, ascending, descending }

class FoodsTable extends StatefulWidget {
  @override
  _FoodsTableState createState() => _FoodsTableState();
}

class _FoodsTableState extends State<FoodsTable> {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  // 사용자 데이터
  List<Map<String, dynamic>> userData = [
    {
      '연번': 1,
      '카테고리': '과일',
      '식품명': '사과',
      '냉장고카테고리': '냉장',
      '장보기카테고리': '과일',
      '소비기한': 20,
      '유통기한': 10,
    },
    {
      '연번': 2,
      '카테고리': '육류',
      '식품명': '닭고기',
      '냉장고카테고리': '냉장',
      '장보기카테고리': '육류',
      '소비기한': 7,
      '유통기한': 3,
    },
    {
      '연번': 3,
      '카테고리': '조미료',
      '식품명': '새우젓',
      '냉장고카테고리': '냉동',
      '장보기카테고리': '조미료',
      '소비기한': 30,
      '유통기한': 50,
    },
  ];

  // 선택된 행의 인덱스를 저장하는 리스트
  List<int> selectedRows = [];

  // 드롭다운 선택 항목들
  final List<String> categoryOptions = ['과일', '육류', '조미료'];
  final List<String> fridgeCategoryOptions = ['냉장', '냉동', '실온'];
  final List<String> shoppingCategoryOptions = ['과일', '육류', '조미료'];

  // 선택된 값들을 저장할 변수들
  String? _selectedCategory;
  String? _selectedFridgeCategory;
  String? _selectedShoppingListCategory;

// 추가할 때 사용할 입력 필드 컨트롤러들
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _shelfLifeController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();

  // 사용자 데이터를 추가하는 함수
  void _addFood() {
    setState(() {
      userData.add({
        '연번': userData.length + 1,
        '카테고리': _selectedCategory,
        '식품명': _foodNameController.text,
        '냉장고카테고리': _selectedFridgeCategory,
        '장보기카테고리': _selectedShoppingListCategory,
        '소비기한': int.tryParse(_shelfLifeController.text) ?? 0,
        '유통기한': int.tryParse(_expirationDateController.text) ?? 0,
      });

      // 입력 필드 초기화

      _foodNameController.clear();
      _shelfLifeController.clear();
      _expirationDateController.clear();
      _selectedCategory = null;
      _selectedFridgeCategory = null;
      _selectedShoppingListCategory = null;
    });
  }

  void _addSampleData() async {
    final newItem = DefaultFoodModel(
      id: _db.collection('default_foods_categories').doc().id, // Firestore 문서 ID 자동 생성
      categories: '육류', // 대분류 카테고리 예시
      itemsByCategory: ['소고기', '돼지고기', '닭고기'], // 소분류 예시
      isDisabled: false,
      isDefaultFridgeCategory: true,
      isShoppingListCategory: true,
      expirationDate: DateTime.now().add(Duration(days: 30)), // 현재 날짜로부터 30일 뒤로 설정
      shelfLife: DateTime.now().add(Duration(days: 60)), // 현재 날짜로부터 60일 뒤로 설정
    );

    try {
      await _db.collection('default_foods_categories').doc(newItem.id).set(newItem.toFirestore());
      print('데이터 추가 성공');
    } catch (e) {
      print('데이터 추가 실패: $e');
    }
  }
// 데이터 수정 버튼 클릭 시 호출할 함수
  void _editFood(int index) {
    setState(() {
      // 수정할 데이터 필드로 값 가져오기
      Map<String, dynamic> selectedFood = userData[index];
      _foodNameController.text = selectedFood['식품명'];
      _shelfLifeController.text = selectedFood['소비기한'].toString();
      _expirationDateController.text = selectedFood['유통기한'].toString();
      _selectedCategory = selectedFood['카테고리'];
      _selectedFridgeCategory = selectedFood['냉장고카테고리'];
      _selectedShoppingListCategory = selectedFood['장보기카테고리'];
    });
  }

  // 체크박스를 사용해 선택한 행 삭제
  void _deleteSelectedRows() {
    setState(() {
      selectedRows.sort((a, b) => b.compareTo(a)); // 역순으로 정렬하여 삭제
      for (var index in selectedRows) {
        userData.removeAt(index);
      }
      selectedRows.clear(); // 삭제 후 선택 초기화
    });
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
              2: FixedColumnWidth(100),
              3: FixedColumnWidth(100),
              4: FixedColumnWidth(120),
              5: FixedColumnWidth(80),
              6: FixedColumnWidth(80),
              7: FixedColumnWidth(120),
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
                        onTap: () => _sortBy(column['name'], column['state']),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(column['name']),
                              Icon(
                                column['state'] == SortState.ascending
                                    ? Icons.arrow_upward
                                    : column['state'] == SortState.descending
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
              2: FixedColumnWidth(100),
              3: FixedColumnWidth(100),
              4: FixedColumnWidth(120),
              5: FixedColumnWidth(80),
              6: FixedColumnWidth(80),
              7: FixedColumnWidth(120),
              8: FixedColumnWidth(80),
            },
            children:  [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        width: 1, color: Colors.black), // 셀 아래 테두리 추가
                  ),
                ),
                children: [
                  TableCell(
                    child: SizedBox.shrink()
                  ),
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
                        onPressed: _addFood,
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
              2: FixedColumnWidth(100),
              3: FixedColumnWidth(100),
              4: FixedColumnWidth(120),
              5: FixedColumnWidth(80),
              6: FixedColumnWidth(80),
              7: FixedColumnWidth(120),
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
            onPressed: selectedRows.isNotEmpty ? _deleteSelectedRows : null,
            child: Text('선택한 항목 삭제'),
          ),
          ElevatedButton(
              onPressed: _addSampleData,
              child: Text('샘플 데이터 추가'),
            ),
        ],

      ),

    );
  }
}

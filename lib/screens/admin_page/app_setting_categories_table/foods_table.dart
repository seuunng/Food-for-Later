import 'package:flutter/material.dart';

enum SortState { none, ascending, descending }

class FoodsTable extends StatefulWidget {
  @override
  _FoodsTableState createState() => _FoodsTableState();
}

class _FoodsTableState extends State<FoodsTable> {
  // 각 열에 대한 정렬 상태를 관리하는 리스트
  List<Map<String, dynamic>> columns = [
    {'name': '연번', 'state': SortState.none},
    {'name': '카테고리', 'state': SortState.none},
    {'name': '식품명', 'state': SortState.none},
    {'name': '냉장고카테고리', 'state': SortState.none},
    {'name': '소비기한', 'state': SortState.none},
    {'name': '유통기한', 'state': SortState.none},
    {'name': '장보기목록카테고리', 'state': SortState.none},
    {'name': '추가', 'state': SortState.none}
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
// 추가할 때 사용할 입력 필드 컨트롤러들
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _fridgeCategoryController =
      TextEditingController();
  final TextEditingController _shelfLifeController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();
  final TextEditingController _shoppingListCategoryController =
      TextEditingController();

  // 사용자 데이터를 추가하는 함수
  void _addFood() {
    setState(() {
      userData.add({
        '연번': userData.length + 1,
        '카테고리': _categoryController.text,
        '식품명': _foodNameController.text,
        '냉장고카테고리': _fridgeCategoryController.text,
        '장보기카테고리': _shoppingListCategoryController.text,
        '소비기한': int.tryParse(_shelfLifeController.text) ?? 0,
        '유통기한': int.tryParse(_expirationDateController.text) ?? 0,
      });

      // 입력 필드 초기화
      _categoryController.clear();
      _foodNameController.clear();
      _fridgeCategoryController.clear();
      _shelfLifeController.clear();
      _expirationDateController.clear();
      _shoppingListCategoryController.clear();
    });
  }

// 데이터 수정 버튼 클릭 시 호출할 함수
  void _editFood(int index) {
    setState(() {
      // 수정할 데이터 필드로 값 가져오기
      Map<String, dynamic> selectedFood = userData[index];
      _categoryController.text = selectedFood['카테고리'];
      _foodNameController.text = selectedFood['식품명'];
      _fridgeCategoryController.text = selectedFood['냉장고카테고리'];
      _shelfLifeController.text = selectedFood['소비기한'].toString();
      _expirationDateController.text = selectedFood['유통기한'].toString();
      _shoppingListCategoryController.text = selectedFood['장보기카테고리'];
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
              0: FixedColumnWidth(60),
              1: FixedColumnWidth(100),
              2: FixedColumnWidth(100),
              3: FixedColumnWidth(120),
              4: FixedColumnWidth(80),
              5: FixedColumnWidth(80),
              6: FixedColumnWidth(120),
              7: FixedColumnWidth(80),
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
                      child: GestureDetector(
                        onTap: () => _sortBy(column['name'], column['state']),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(column['name']),
                              if (column['state'] == SortState.ascending)
                                Icon(Icons.arrow_upward, size: 12),
                              if (column['state'] == SortState.descending)
                                Icon(Icons.arrow_downward, size: 12),
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
              0: FixedColumnWidth(60),
              1: FixedColumnWidth(100),
              2: FixedColumnWidth(100),
              3: FixedColumnWidth(120),
              4: FixedColumnWidth(80),
              5: FixedColumnWidth(80),
              6: FixedColumnWidth(120),
              7: FixedColumnWidth(80),
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
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Center(child: Text('no'))),
                  TableCell(
                    child: TextField(
                      controller: _categoryController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '카테고리',
                        hintStyle: TextStyle(
                          fontSize: 12, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        filled: true, // 배경색 추가
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  TableCell(
                    child: TextField(
                      controller: _foodNameController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '식품명',
                        hintStyle: TextStyle(
                          fontSize: 12, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        filled: true, // 배경색 추가
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  TableCell(
                    child: TextField(
                      controller: _fridgeCategoryController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '냉장고 카테고리',
                        hintStyle: TextStyle(
                          fontSize: 12, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        filled: true, // 배경색 추가
                        fillColor: Colors.grey[200],
                      ),
                    ),
                  ),
                  TableCell(
                    child: TextField(
                      controller: _shelfLifeController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '소비기한',
                        hintStyle: TextStyle(
                          fontSize: 12, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        filled: true, // 배경색 추가
                        fillColor: Colors.grey[200],
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  TableCell(
                    child: TextField(
                      controller: _expirationDateController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '유통기한',
                        hintStyle: TextStyle(
                          fontSize: 12, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        filled: true, // 배경색 추가
                        fillColor: Colors.grey[200],
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  TableCell(
                    child: TextField(
                      controller: _shoppingListCategoryController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '장보기 카테고리',
                        hintStyle: TextStyle(
                          fontSize: 12, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        filled: true, // 배경색 추가
                        fillColor: Colors.grey[200],
                      ),
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
              0: FixedColumnWidth(60),
              1: FixedColumnWidth(100),
              2: FixedColumnWidth(100),
              3: FixedColumnWidth(120),
              4: FixedColumnWidth(80),
              5: FixedColumnWidth(80),
              6: FixedColumnWidth(120),
              7: FixedColumnWidth(80),
            },
            children: userData.map((row) {
              return TableRow(
                children: [
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
                      onPressed: () => _editFood(row['연번']), // 수정 버튼 클릭 시
                      child: Text('수정'),
                    ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

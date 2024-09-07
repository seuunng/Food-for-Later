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
      '연번': 3,
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
      '식품명': '새우젖',
      '냉장고카테고리': '냉동',
      '장보기카테고리': '조미료',
      '소비기한': 30,
      '유통기한': 50,
    },
  ];
// 추가할 때 사용할 입력 필드 컨트롤러들
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _fridgeCategoryController = TextEditingController();
  final TextEditingController _shelfLifeController = TextEditingController();
  final TextEditingController _expirationDateController = TextEditingController();
  final TextEditingController _shoppingListCategoryController = TextEditingController();

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
          // 테이블의 제목 셀
          DataTable(
            columns: columns.map((column) {
              return DataColumn(
                label: GestureDetector(
                  onTap: () => _sortBy(column['name'], column['state']),
                  child: Row(
                    children: [
                      Text(column['name']),
                      Icon(
                        column['state'] == SortState.ascending
                            ? Icons.arrow_upward
                            : column['state'] == SortState.descending
                            ? Icons.arrow_downward
                            : Icons.sort,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            rows: [], // 여기는 데이터가 없으므로 빈 리스트 유지
          ),

          // 입력 필드들이 들어간 행
          Row(
            children: [
              Container(
                width: 60,
                child: Text('자동'), // 연번 자동으로 증가하므로 입력 X
              ),
              Container(
                width: 100,
                child: TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    hintText: '카테고리',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                width: 100,
                child: TextField(
                  controller: _foodNameController,
                  decoration: InputDecoration(
                    hintText: '식품명',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                width: 120,
                child: TextField(
                  controller: _fridgeCategoryController,
                  decoration: InputDecoration(
                    hintText: '냉장고 카테고리',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Container(
                width: 80,
                child: TextField(
                  controller: _shelfLifeController,
                  decoration: InputDecoration(
                    hintText: '소비기한',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Container(
                width: 80,
                child: TextField(
                  controller: _expirationDateController,
                  decoration: InputDecoration(
                    hintText: '유통기한',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              Container(
                width: 120,
                child: TextField(
                  controller: _shoppingListCategoryController,
                  decoration: InputDecoration(
                    hintText: '장보기 카테고리',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _addFood,
                child: Text('추가'),
              ),
            ],
          ),

          // 데이터가 추가되는 테이블
          DataTable(
            columns: columns.map((column) {
              return DataColumn(
                label: Text(column['name']), // 여기는 반드시 이름 지정
              );
            }).toList(),
            rows: userData.map((row) {
              return DataRow(
                cells: columns.map((column) {
                  return DataCell(Text(row[column['name']].toString()));
                }).toList(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

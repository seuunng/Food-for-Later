import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/recipe_method_model.dart';

enum SortState { none, ascending, descending }

class HowtocookTable extends StatefulWidget {
  @override
  _HowtocookTableState createState() => _HowtocookTableState();
}

class _HowtocookTableState extends State<HowtocookTable> {

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 각 열에 대한 정렬 상태를 관리하는 리스트
  List<Map<String, dynamic>> columns = [
    {'name': '선택', 'state': SortState.none},
    {'name': '연번', 'state': SortState.none},
    {'name': '조리방법명', 'state': SortState.none},
    {'name': '변동', 'state': SortState.none}
  ];

  // 사용자 데이터
  List<Map<String, dynamic>> userData = [
    {
      '연번': 1,
      '조리방법명': '끓이기',
    },
    {
      '연번': 2,
      '조리방법명': '데치기',
    },
    {
      '연번': 3,
      '조리방법명': '에어프라이어',
    },
  ];

  // 선택된 행의 인덱스를 저장하는 리스트
  List<int> selectedRows = [];

  // 드롭다운 선택 항목들
  final List<String> categoryOptions = ['끓이기', '데치기', '에어프라이어', '오븐'];

// 추가할 때 사용할 입력 필드 컨트롤러들
  final TextEditingController _methodNameController = TextEditingController();

  // 사용자 데이터를 추가하는 함수
  void _addMethod() {
    setState(() {
      userData.add({
        '연번': userData.length + 1,
        '조리방법명': _methodNameController.text,
      });

      // 입력 필드 초기화

      _methodNameController.clear();
    });
  }

  void _addSampleData() async {
    final newItem = RecipeMethodModel(
      id: _db.collection('recipe_method_categories').doc().id, // Firestore 문서 ID 자동 생성
      categories: '', // 대분류 카테고리 예시
      method: ['끓이기', '데치기', '오븐','튀기기','에어프라이어','삶기','전자렌지','볶기'], // 소
    );

    try {
      await _db.collection('recipe_method_categories').doc(newItem.id).set(newItem.toFirestore());
      print('데이터 추가 성공');
    } catch (e) {
      print('데이터 추가 실패: $e');
    }
  }

// 데이터 수정 버튼 클릭 시 호출할 함수
  void _editMethod(int index) {
    setState(() {
      // 수정할 데이터 필드로 값 가져오기
      Map<String, dynamic> selectedFood = userData[index];
      _methodNameController.text = selectedFood['조리방법명'];
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
              0: FixedColumnWidth(40),
              1: FixedColumnWidth(80),
              2: FixedColumnWidth(160),
              3: FixedColumnWidth(80),
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
              1: FixedColumnWidth(80),
              2: FixedColumnWidth(160),
              3: FixedColumnWidth(80),
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
                    child: TextField(
                      controller: _methodNameController,
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '조리방법명',
                        hintStyle: TextStyle(
                          fontSize: 14, // 글씨 크기 줄이기
                          color: Colors.grey, // 글씨 색상 회색으로
                        ),
                        suffixIcon: _methodNameController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _methodNameController
                                        .clear(); // 입력 필드 내용 삭제
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
                    child: SizedBox(
                      width: 60, // 버튼의 너비를 설정
                      height: 30, // 버튼의 높이를 설정
                      child: ElevatedButton(
                        onPressed: _addMethod,
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
              1: FixedColumnWidth(80),
              2: FixedColumnWidth(160),
              3: FixedColumnWidth(80),
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
                      child: Center(child: Text(row['조리방법명']))),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: SizedBox(
                      width: 60, // 버튼의 너비를 설정
                      height: 30, // 버튼의 높이를 설정
                      child: ElevatedButton(
                        onPressed: () => _editMethod(row['연번'] - 1), // 수정 버튼 클릭 시
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

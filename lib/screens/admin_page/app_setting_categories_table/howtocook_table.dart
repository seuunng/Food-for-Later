import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/models/recipe_method_model.dart';

enum SortState { none, ascending, descending }

class HowtocookTable extends StatefulWidget {
  @override
  _HowtocookTableState createState() => _HowtocookTableState();
}

class _HowtocookTableState extends State<HowtocookTable> {
  List<Map<String, dynamic>> columns = [
    {'name': '선택', 'state': SortState.none},
    {'name': '연번', 'state': SortState.none},
    {'name': '조리방법명', 'state': SortState.none},
    {'name': '변동', 'state': SortState.none}
  ];

  // 사용자 데이터
  List<Map<String, dynamic>> userData = [];

  // 선택된 행의 인덱스를 저장하는 리스트
  List<int> selectedRows = [];

  bool isEditing = false;
  int? selectedThemesIndex;

  final TextEditingController _methodNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMethodsData();
    // addSampleTheme();
  }

  Future<void> _loadMethodsData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('recipe_method_categories')
        .get();

    List<Map<String, dynamic>> methods = [];

    snapshot.docs.forEach((doc) {
      final method = RecipeMethodModel.fromFirestore(doc);
print(method.method);
      methods.add({
        '연번': methods.length + 1, // 연번은 자동으로 증가하도록 설정
        '조리방법명': method.method,
        'documentId': doc.id,
      });
    });

    setState(() {
      userData = methods;
    });
  }

  // 사용자 데이터를 추가하는 함수
  void _addMethod(String newMethod) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('recipe_method_categories')
    .doc('documentId');

    await snapshot.update({
      'method': FieldValue.arrayUnion([newMethod]), // 배열에 새로운 항목 추가
    });

    userData.add({
      '조리방법명': newMethod,
    });

    _methodNameController.clear();
  }

  // void _addSampleData() async {
  //   final newItem = RecipeMethodModel(
  //     id: _db.collection('recipe_method_categories').doc().id, // Firestore 문서 ID 자동 생성
  //     categories: '', // 대분류 카테고리 예시
  //     method: ['끓이기', '데치기', '오븐','튀기기','에어프라이어','삶기','전자렌지','볶기'], // 소
  //   );
  //
  //   try {
  //     await _db.collection('recipe_method_categories').doc(newItem.id).set(newItem.toFirestore());
  //     print('데이터 추가 성공');
  //   } catch (e) {
  //     print('데이터 추가 실패: $e');
  //   }
  // }

// 데이터 수정 버튼 클릭 시 호출할 함수

  void _editMethod(int index) {
    final selectedMethod = userData[index];

    setState(() {
      _methodNameController.text = selectedMethod['조리방법명'] ?? '';
    });
    isEditing = true;
    selectedThemesIndex = index;
  }

  void _updateMethod(int index, String updatedMethod) async {
    final selectedMethod = userData[index];
    final String? documentId = selectedMethod['documentId'];
    if (documentId != null) {
      try {
        // Firestore에서 해당 문서 가져오기
        final snapshot = await FirebaseFirestore.instance
            .collection('recipe_method_categories')
            .doc(documentId)
            .get();
    if (snapshot.exists) {
      // 기존의 method 배열 가져오기
      List<dynamic> methodList = snapshot.data()?['method'] ?? [];

      // 배열 안에서 수정할 항목의 인덱스를 찾기
      int methodIndex = methodList.indexWhere(
              (method) => method == selectedMethod['조리방법명']);

      if (methodIndex != -1) {
        // 배열의 해당 항목을 수정
        methodList[methodIndex] = updatedMethod.isNotEmpty
            ? updatedMethod
            : selectedMethod['조리방법명'];

        // Firestore에 업데이트
        await FirebaseFirestore.instance
            .collection('recipe_method_categories')
            .doc(documentId)
            .update({
          'method': methodList, // 수정된 배열로 업데이트
        });

        setState(() {
          // 로컬 데이터도 업데이트
          userData[index]['조리방법명'] = updatedMethod.isNotEmpty
              ? updatedMethod
              : selectedMethod['조리방법명'];
        });

        print('조리 방법이 성공적으로 업데이트되었습니다.');
      } else {
        print('해당 조리 방법을 찾을 수 없습니다.');
      }
    }
      } catch (e) {
        print('Firestore에 데이터를 업데이트하는 중 오류가 발생했습니다: $e');
      }
    }
  }

  // 체크박스를 사용해 선택한 행 삭제
  void _deleteSelectedRows(int index) async {
    final selectedMethod = userData[index];

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
        });
    if (shouldDelete == true) {
      try {
        final String? documentId = selectedMethod['documentId'];
        if (documentId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('recipe_method_categories')
            .doc(documentId);

          await snapshot.delete();

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
    await _loadMethodsData();
    setState(() {}); // 화면을 새로고침
  }

  void _clearFields() {
    _methodNameController.clear();
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
                        onPressed: () {
                          // final TextEditingController themesNameController = TextEditingController();

                          if (isEditing) {
                            if (selectedThemesIndex != null) {
                              _updateMethod(selectedThemesIndex!,
                                  _methodNameController.text);
                            }
                          } else {
                            if (_methodNameController != null)
                              _addMethod(_methodNameController.text);
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
                        onPressed: () =>
                            _editMethod(row['연번'] - 1), // 수정 버튼 클릭 시
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

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';

import '../admin_page/admin_feedback_management.dart';

class EditRecordCategories extends StatefulWidget {
  @override
  _EditRecordCategoriesState createState() => _EditRecordCategoriesState();
}

class _EditRecordCategoriesState extends State<EditRecordCategories> {
  // 각 열에 대한 정렬 상태를 관리하는 리스트
  List<Map<String, dynamic>> columns = [
    {'name': '선택', 'state': SortState.none},
    {'name': '연번', 'state': SortState.none},
    {'name': '기록 카테고리', 'state': SortState.none},
    {'name': '분류', 'state': SortState.none},
    {'name': '변동', 'state': SortState.none}
  ];

  // 사용자 데이터
  List<Map<String, dynamic>> userData = [
    {
      '연번': 1,
      '기록 카테고리': '식단',
      '분류': [
        '아침',
        '점심',
        '저녁',
      ],
      '색상': Colors.blue[100] //
    },
    {
      '연번': 2,
      '기록 카테고리': '운동',
      '분류': [
        '아침',
        '점심',
        '저녁',
      ],
      '색상': Colors.green[100]
    },
    {
      '연번': 3,
      '기록 카테고리': '자기개발',
      '분류': [
        '아침',
        '점심',
        '저녁',
      ],
      '색상': Colors.orange[100]
    },
  ];

  final TextEditingController _recordCategoryController =
      TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  Color _selectedColor = Colors.grey[300]!; // 기본 색상

  List<String> units = [];
  // 데이터 추가 함수
  void _addOrEditCategory({int? index}) {
    if (index != null) {
      // 수정 모드
      _recordCategoryController.text = userData[index]['기록 카테고리'];
      units = List<String>.from(userData[index]['분류']);
      _selectedColor = userData[index]['색상'] ?? Colors.grey[300];
    } else {
      // 추가 모드 초기화
      _recordCategoryController.clear();
      units = [];
      _selectedColor = Colors.grey[300]!; // 초기 색상
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(index == null ? '카테고리 추가' : '카테고리 수정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                      TextField(
                        controller: _recordCategoryController,
                        decoration: InputDecoration(
                          labelText: '기록 카테고리',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.0, // 텍스트 필드 내부 좌우 여백 조절
                            vertical: 8.0, // 텍스트 필드 내부 상하 여백 조절
                          ),
                        ),
                      ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: 8.0,
                    children: [
                      for (var color in [
                        Color(0xFFFFC1CC), // 핑크 블러쉬
                        Color(0xFFB2EBF2), // 민트 블루
                        Color(0xFFD1C4E9), // 라벤더 퍼플
                        Color(0xFFFFE0B2), // 피치 오렌지
                        Color(0xFFFFF9C4), // 바닐라 옐로우
                        Color(0xFFDCEDC8), // 라이트 그린
                        Color(0xFFBBDEFB), // 스카이 블루
                        Color(0xFFE1BEE7), // 라일락 퍼플
                        Color(0xFFD7CCC8), // 소프트 베이지
                      ])
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedColor == color ? Colors.black : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 0.0,
                    children: units.map((unit) {
                      return Chip(
                        label: Text(unit),
                        labelPadding: EdgeInsets.symmetric(
                          horizontal: 4.0, // 라벨(텍스트)과 좌우 경계 사이의 여백
                          vertical: 0.0, // 라벨(텍스트)과 상하 경계 사이의 여백
                        ),
                        padding: EdgeInsets.all(0),
                        deleteIcon: Transform.translate(
                          offset: Offset(-4, 0), // x, y 좌표로 이동, x는 좌우, y는 상하
                          child: Icon(
                            Icons.close,
                            size: 16.0, // 삭제 아이콘 크기
                          ),
                        ),
                        onDeleted: () {
                          setState(() {
                            units.remove(unit);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: _unitController,
                    decoration: InputDecoration(
                      labelText: '분류 추가',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8.0, // 텍스트 필드 내부 좌우 여백 조절
                        vertical: 8.0, // 텍스트 필드 내부 상하 여백 조절
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            String newUnit = _unitController.text.trim();
                            if (newUnit.isEmpty) {
                              // 빈 문자열인 경우 추가하지 않음
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('빈 분류는 추가할 수 없습니다.'),
                                ),
                              );
                            } else if (units.contains(newUnit)) {
                              // 중복된 이름인 경우 추가하지 않음
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('이미 존재하는 분류입니다.'),
                                ),
                              );
                            } else if (units.length >= 5) {
                              // 분류의 개수가 5개 이상인 경우 추가하지 않음
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('최대 5개의 분류만 추가할 수 있습니다.'),
                                ),
                              );
                            } else {
                              // 새로운 분류 추가
                              units.add(newUnit);
                              _unitController.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (index == null) {
                        // 추가 모드
                        userData.add({
                          '연번': userData.length + 1,
                          '기록 카테고리': _recordCategoryController.text,
                          '분류': List.from(units),
                          '색상': _selectedColor,
                        });
                      } else {
                        // 수정 모드
                        userData[index] = {
                          '연번': userData[index]['연번'],
                          '기록 카테고리': _recordCategoryController.text,
                          '분류': List.from(units),
                          '색상': _selectedColor,
                        };
                      }
                    });
                    _recordCategoryController.clear();
                    _unitController.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text(index == null ? '추가' : '수정'),
                ),
              ],
            );
          },
        );
      },
    );
  }

// 색상 선택 다이얼로그
  Future<Color?> _showColorPicker(BuildContext context) async {
    Color selectedColor = _selectedColor;
    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('색상 선택'),
          content: SingleChildScrollView(
            //컬러 팔레드
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = Colors.red;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == Colors.red ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = Colors.blue;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == Colors.blue ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                // 다른 색상들도 동일한 방식으로 추가 가능
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(selectedColor);
              },
            ),
          ],
          );

      },
    );
  }

  // 데이터 삭제 함수
  void _deleteCategory(int index) {
    setState(() {
      userData.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기록 카테고리 관리'),
      ),
      body: ListView.builder(
        itemCount: userData.length,
        itemBuilder: (context, index) {
          final record = userData[index];
          return Dismissible(
              key: Key(record['연번'].toString()), // 각 항목에 고유한 키를 부여
              direction: DismissDirection.endToStart, // 오른쪽에서 왼쪽으로만 스와이프 가능
              onDismissed: (direction) {
                _deleteCategory(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${record['기록 카테고리']} 삭제됨')),
                );
              },
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                color: record['색상'] ?? Colors.grey[300],
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  // leading: CircleAvatar(
                  //   child: Text(record['연번'].toString()),
                  // ),
                  title: Text(
                    record['기록 카테고리'],
                    style: TextStyle(
                      fontSize: 18.0, // 제목 글씨 크기 키우기
                      fontWeight: FontWeight.bold, // 제목 글씨 굵게
                    ),
                  ),
                  subtitle: Text(
                    '${record['분류'].join(', ')}',
                    style: TextStyle(
                      fontSize: 18.0, // 분류 글씨 크기 키우기
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                        ),
                        onPressed: () => _addOrEditCategory(index: index),
                      ),
                    ],
                  ),
                ),
              ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'record_category_add_button',
        onPressed: () => _addOrEditCategory(),
        child: Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게
        ),
      ),
    );
  }
}

// 정렬 상태 enum
enum SortState { none, ascending, descending }

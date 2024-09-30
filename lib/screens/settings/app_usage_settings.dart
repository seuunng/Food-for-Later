import 'package:flutter/material.dart';
import 'package:food_for_later/screens/foods/manage_categories.dart';
import 'package:food_for_later/screens/fridge/add_item.dart';
import 'package:food_for_later/components/custom_dropdown.dart';

class AppUsageSettings extends StatefulWidget {
  @override
  _AppUsageSettingsState createState() => _AppUsageSettingsState();
}

class _AppUsageSettingsState extends State<AppUsageSettings> {
  String _selectedCategory_fridge = '기본 냉장고'; // 기본 선택값
  final List<String> _categories_fridge = ['기본 냉장고', '김치 냉장고']; // 카테고리 리스트
  String _selectedCategory_fridgeCategory = '냉장'; // 기본 선택값
  final List<String> _categories_fridgeCategory = [
    '냉장',
    '냉동',
    '실온'
  ]; // 카테고리 리스트
  String _selectedCategory_foods = '입고일 기준'; // 기본 선택값
  final List<String> _categories_foods = ['소비기한 기준', '입고일 기준']; // 카테고리 리스트
  String _selectedCategory_records = '앨범형'; // 기본 선택값
  final List<String> _categories_records = ['앨범형', '달력형', '목록형']; // 카테고리 리스트

  String _newCategory = '';

  // 새로운 카테고리 추가 함수
  void _addNewCategory(List<String> categories, String categoryType) {
    if (categories.length >= 3) {
      // 카테고리 개수가 3개 이상이면 추가 불가
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$categoryType은(는) 최대 3개까지만 추가할 수 있습니다.'),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCategory = '';
        return AlertDialog(
          title: Text('$categoryType 추가'),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: InputDecoration(hintText: '새로운 카테고리 입력'),
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  setState(() {
                    categories.add(newCategory);
                    // 추가 후 선택된 카테고리 업데이트
                    if (categoryType == '냉장고') {
                      _selectedCategory_fridge = newCategory;
                    } else if (categoryType == '냉장고 카테고리') {
                      _selectedCategory_fridgeCategory = newCategory;
                    }
                  });
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // 선택된 냉장고 삭제 함수
  void _deleteCategory(
      String category, List<String> categories, String categoryType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('냉장고 삭제'),
          content: Text('$category를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                setState(() {
                  _categories_fridge.remove(category);
                  // 냉장고 또는 냉장고 카테고리 삭제 후 기본 선택값으로 변경
                  if (categoryType == '냉장고') {
                    _selectedCategory_fridge =
                        categories.isNotEmpty ? categories.first : '';
                  } else if (categoryType == '냉장고 카테고리') {
                    _selectedCategory_fridgeCategory =
                        categories.isNotEmpty ? categories.first : '';
                  }
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _saveSettings() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('어플 사용 설정'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown(
                title: '냉장고 선택',
                items: _categories_fridge,
                selectedItem: _selectedCategory_fridge,
                onItemChanged: (value) {
                  setState(() {
                    _selectedCategory_fridge = value;
                  });
                },
                onItemDeleted: (item) {
                  _deleteCategory(item, _categories_fridge, '냉장고');
                },
                onAddNewItem: () {
                  _addNewCategory(_categories_fridge, '냉장고');
                },
              ),
              Text('가장 자주 보는 냉장고를 기본냉장고로 설정하세요'),
              SizedBox(height: 20),
              CustomDropdown(
                title: '냉장고 카테고리 선택',
                items: _categories_fridgeCategory,
                selectedItem: _selectedCategory_fridgeCategory,
                onItemChanged: (value) {
                  setState(() {
                    _selectedCategory_fridgeCategory = value;
                  });
                },
                onItemDeleted: (item) {
                  _deleteCategory(item, _categories_fridgeCategory, '냉장고 카테고리');
                },
                onAddNewItem: () {
                  _addNewCategory(_categories_fridgeCategory, '냉장고 카테고리');
                },
              ),
              // Row(
              //   children: [
              //     Text(
              //       '냉장고 카테고리 선택',
              //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //     ),
              //     Spacer(),
              //     PopupMenuButton<String>(
              //       onSelected: (String value) {
              //         if (value == '추가') {
              //           _addNewCategory(_categories_fridgeCategory, '냉장고 카테고리');
              //         } else {
              //           setState(() {
              //             _selectedCategory_fridgeCategory = value;
              //           });
              //         }
              //       },
              //       itemBuilder: (BuildContext context) {
              //         return _categories_fridgeCategory.map((String category) {
              //           return PopupMenuItem<String>(
              //             value: category,
              //             child: Row(
              //               children: [
              //                 Expanded(
              //                   child: Text(category),
              //
              //                 ),
              //                 IconButton(
              //                   icon: Icon(Icons.close,
              //                       color: Colors.black, size: 16),
              //                   onPressed: () {
              //                     _deleteCategory(category,
              //                         _categories_fridgeCategory, '냉장고 카테고리');
              //                   },
              //                 ),
              //               ],
              //             ),
              //           );
              //         }).toList()
              //           ..add(
              //             PopupMenuItem<String>(
              //               value: '추가',
              //               child: Row(
              //                 children: [
              //                   Icon(Icons.add, color: Colors.blue),
              //                   SizedBox(width: 8),
              //                   Text('새 카테고리 추가'),
              //                 ],
              //               ),
              //             ),
              //           );
              //       },
              //       child: Row(
              //         children: [
              //           Text(
              //             _selectedCategory_fridgeCategory.isNotEmpty
              //                 ? _selectedCategory_fridgeCategory
              //                 : '카테고리 선택',
              //           ),
              //           Icon(Icons.arrow_drop_down),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              Text('냉장고 속 분류 기준을 설정하세요'),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    '식품 상태관리 선택',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  DropdownButton<String>(
                    value: _categories_foods.contains(_selectedCategory_foods)
                        ? _selectedCategory_foods
                        : null,
                    items: _categories_foods.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory_foods = newValue!;
                      });
                    },
                  ),
                ],
              ),
              Text('식품 관리 기준을 선택하세요'),
              Text('빨리 소진해야할 식품을 알려드려요'),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    '선호 식품 카테고리 수정',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddItem(
                            pageTitle: '선호식품 카테고리에 추가',
                            addButton: '카테고리에 추가',
                            fridgeFieldIndex: '기본냉장고',
                            basicFoodsCategories: [
                              '비건',
                              '다이어트',
                              '무오신채',
                              '알레르기',
                              '채식'
                            ], // 원하는 카테고리 리스트), // 의견 보내기 페이지로 이동
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 18), // 작은 크기의 수정 아이콘 추가
                        SizedBox(width: 8), // 아이콘과 텍스트 사이의 간격
                        Text('수정'),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors. blueGrey, // 텍스트 및 아이콘 색상
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20), // 버튼 내부 패딩
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // 버튼 모서리 둥글게
                      ),
                      elevation: 5, // 버튼 그림자
                    ),

                  ),
                ],
              ),
              Text('자주 검색하는 식품을 묶음으로 관리해요'),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    '대표 기록유형 선택',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  DropdownButton<String>(
                    value:
                        _categories_records.contains(_selectedCategory_records)
                            ? _selectedCategory_records
                            : null,
                    items: _categories_records.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory_records = newValue!;
                      });
                    },
                  ),
                ],
              ),
              Text('가장 자주 보는 기록유형을 대표 유형으로 설정하세요'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveSettings,
          child: Text('저장'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

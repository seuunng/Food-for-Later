import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/components/basic_elevated_button.dart';
import 'package:food_for_later/components/navbar_button.dart';
import 'package:food_for_later/screens/foods/add_item.dart';
import 'package:food_for_later/components/custom_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUsageSettings extends StatefulWidget {
  @override
  _AppUsageSettingsState createState() => _AppUsageSettingsState();
}

class _AppUsageSettingsState extends State<AppUsageSettings> {
  String _selectedCategory_fridge = '기본 냉장고' ; // 기본 선택값
  List<String> _categories_fridge = []; // 카테고리 리스트
  // String _selectedCategory_fridgeCategory = '냉장'; // 기본 선택값
  // final List<String> _categories_fridgeCategory = [
  //   '냉장',
  //   '냉동',
  //   '실온'
  // ]; // 카테고리 리스트
  String _selectedCategory_foods = '입고일 기준'; // 기본 선택값
  final List<String> _categories_foods = ['소비기한 기준', '입고일 기준']; // 카테고리 리스트
  String _selectedCategory_records = '앨범형'; // 기본 선택값
  final List<String> _categories_records = ['앨범형', '달력형', '목록형']; // 카테고리 리스트

  String _newCategory = '';
  @override
  void initState() {
    super.initState();
    _loadFridgeCategoriesFromFirestore(); // 초기화 시 Firestore에서 데이터를 불러옴
  }

  // Firestore에서 냉장고 목록 불러오기
  void _loadFridgeCategoriesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('fridges').get();
      List<String> fridgeList = snapshot.docs.map((doc) => doc['FridgeName'] as String).toList();

      if (fridgeList.isEmpty) {
        await _createDefaultFridge(); // 기본 냉장고 추가
      }

      setState(() {
        _categories_fridge = fridgeList; // 불러온 냉장고 목록을 상태에 저장
        // _selectedCategory_fridge = _categories_fridge.isNotEmpty ? _categories_fridge.first : '기본 냉장고';
      });
    } catch (e) {
      print('Error loading fridge categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('냉장고 목록을 불러오는 데 실패했습니다.')),
      );
    }
  }

  Future<void> _createDefaultFridge() async {
    try {
      // Firestore에 기본 냉장고 추가
      await FirebaseFirestore.instance.collection('fridges').add({
        'FridgeName': '기본 냉장고',
      });
      // UI 업데이트
      setState(() {
        _categories_fridge.add('기본 냉장고');
        _selectedCategory_fridge = '기본 냉장고';
      });
    } catch (e) {
      print('Error creating default fridge: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('기본 냉장고를 생성하는 데 실패했습니다.')),
      );
    }
  }

  Future<void> _addNewFridgeToFirestore(String newFridgeName, String userId) async {
    final fridgeRef = FirebaseFirestore.instance.collection('fridges');
    try {
      await fridgeRef.add({
        'FridgeName': newFridgeName,
        'UserID': userId,
      });
    } catch (e) {
      print('냉장고 추가 중 오류가 발생했습니다: $e');
    }
  }

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
              onPressed: () async {
                if (newCategory.isNotEmpty) {
                  await _addNewFridgeToFirestore(newCategory, '현재 유저 아이디');
                  setState(() {
                    categories.add(newCategory);
                    // 추가 후 선택된 카테고리 업데이트
                    if (categoryType == '냉장고') {
                      _selectedCategory_fridge = newCategory;
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
    final fridgeRef = FirebaseFirestore.instance.collection('fridges');
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
              onPressed: () async {
                try {
                  // 해당 냉장고 이름과 일치하는 문서를 찾음
                  final snapshot = await fridgeRef
                      .where('FridgeName', isEqualTo: category)
                      .get();

                  for (var doc in snapshot.docs) {
                    // Firestore에서 문서 삭제
                    await fridgeRef.doc(doc.id).delete();
                  }

                  // UI 업데이트
                  setState(() {
                    _categories_fridge.remove(category);
                    if (_categories_fridge.isNotEmpty) {
                      _selectedCategory_fridge = _categories_fridge.first;
                    } else {
                      _createDefaultFridge(); // 모든 냉장고가 삭제되면 기본 냉장고 생성
                    }
                  });

                  Navigator.pop(context);
                } catch (e) {
                  print('Error deleting fridge: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('냉장고를 삭제하는 중 오류가 발생했습니다.')),
                  );
                  Navigator.pop(context);
                };
              }
            ),
          ],
        );
      },
    );
  }

  void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFridge', _selectedCategory_fridge);
    print(_selectedCategory_fridge);
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
                selectedItem: _categories_fridge.contains(_selectedCategory_fridge)
                    ? _selectedCategory_fridge!
                    : (_categories_fridge.isNotEmpty ? _categories_fridge.first : '기본 냉장고'),
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
              // CustomDropdown(
              //   title: '냉장고 카테고리 선택',
              //   items: _categories_fridgeCategory,
              //   selectedItem: _selectedCategory_fridgeCategory,
              //   onItemChanged: (value) {
              //     setState(() {
              //       _selectedCategory_fridgeCategory = value;
              //     });
              //   },
              //   onItemDeleted: (item) {
              //     _deleteCategory(item, _categories_fridgeCategory, '냉장고 카테고리');
              //   },
              //   onAddNewItem: () {
              //     _addNewCategory(_categories_fridgeCategory, '냉장고 카테고리');
              //   },
              // ),
              // // Row(
              // //   children: [
              // //     Text(
              // //       '냉장고 카테고리 선택',
              // //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // //     ),
              // //     Spacer(),
              // //     PopupMenuButton<String>(
              // //       onSelected: (String value) {
              // //         if (value == '추가') {
              // //           _addNewCategory(_categories_fridgeCategory, '냉장고 카테고리');
              // //         } else {
              // //           setState(() {
              // //             _selectedCategory_fridgeCategory = value;
              // //           });
              // //         }
              // //       },
              // //       itemBuilder: (BuildContext context) {
              // //         return _categories_fridgeCategory.map((String category) {
              // //           return PopupMenuItem<String>(
              // //             value: category,
              // //             child: Row(
              // //               children: [
              // //                 Expanded(
              // //                   child: Text(category),
              // //
              // //                 ),
              // //                 IconButton(
              // //                   icon: Icon(Icons.close,
              // //                       color: Colors.black, size: 16),
              // //                   onPressed: () {
              // //                     _deleteCategory(category,
              // //                         _categories_fridgeCategory, '냉장고 카테고리');
              // //                   },
              // //                 ),
              // //               ],
              // //             ),
              // //           );
              // //         }).toList()
              // //           ..add(
              // //             PopupMenuItem<String>(
              // //               value: '추가',
              // //               child: Row(
              // //                 children: [
              // //                   Icon(Icons.add, color: Colors.blue),
              // //                   SizedBox(width: 8),
              // //                   Text('새 카테고리 추가'),
              // //                 ],
              // //               ),
              // //             ),
              // //           );
              // //       },
              // //       child: Row(
              // //         children: [
              // //           Text(
              // //             _selectedCategory_fridgeCategory.isNotEmpty
              // //                 ? _selectedCategory_fridgeCategory
              // //                 : '카테고리 선택',
              // //           ),
              // //           Icon(Icons.arrow_drop_down),
              // //         ],
              // //       ),
              // //     ),
              // //   ],
              // // ),
              // Text('냉장고 속 분류 기준을 설정하세요'),
              // SizedBox(height: 20),
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
                  BasicElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddItem(
                            pageTitle: '선호식품 카테고리에 추가',
                            addButton: '카테고리에 추가',
                            sourcePage: 'update_foods_category',
                            onItemAdded: () {
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                    iconTitle: Icons.edit,
                    buttonTitle: '수정',
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
        child: NavbarButton(
          buttonTitle: '저장',
          onPressed: _saveSettings,
        ),
      ),
    );
  }
}

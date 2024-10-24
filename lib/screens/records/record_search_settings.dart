import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/components/navbar_button.dart';
import 'package:food_for_later/models/record_category_model.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordSearchSettings extends StatefulWidget {
  @override
  _RecordSearchSettingsState createState() => _RecordSearchSettingsState();
}

class _RecordSearchSettingsState extends State<RecordSearchSettings> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<String> selectedCategories = ['모두'];
  String? selectedPeriod = '1년';
  DateTime? startDate;
  DateTime? endDate;

  Map<String, bool> categoryOptions = {};

  List<String> periods = ['사용자 지정', '1주', '1달', '3달', '1년'];

  @override
  void initState() {
    super.initState();
    _loadCategoryFromFirestore();
    _loadSearchSettingsFromLocal();
  }

  void _loadCategoryFromFirestore() async {
    try {
      final snapshot = await _db.collection('record_categories').get();
      final categories = snapshot.docs.map((doc) {
        return RecordCategoryModel.fromFirestore(doc);
      }).toList();

      setState(() {
        categoryOptions = {
          '모두': selectedCategories.contains('모두'),
          for (var category in categories)
            category.zone: selectedCategories.contains(category.zone),
        };
      });
    } catch (e) {
      print('카테고리 데이터를 불러오는 데 실패했습니다: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리 데이터를 불러오는 데 실패했습니다.')),
      );
    }
  }

  Future<void> _loadSearchSettingsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCategories = prefs.getStringList('selectedCategories') ?? ['모두'];

      final startDateString = prefs.getString('startDate');
      startDate = startDateString != null && startDateString.isNotEmpty
          ? DateTime.parse(startDateString)
          : DateTime(DateTime.now().year - 1, DateTime.now().month,
              DateTime.now().day);
      final endDateString = prefs.getString('endDate');
      endDate = endDateString != null && endDateString.isNotEmpty
          ? DateTime.parse(endDateString)
          : DateTime.now();
      selectedPeriod = prefs.getString('selectedPeriod') ?? '1년';

      categoryOptions.updateAll((key, value) {
        return selectedCategories.contains(key); // 선택된 카테고리를 반영
      });

      // '모두'가 아닌 카테고리가 저장된 경우 '모두' 선택 해제
      if (!selectedCategories.contains('모두')) {
        categoryOptions['모두'] = false;
      } else {
        categoryOptions.updateAll((key, value) => false);
        categoryOptions['모두'] = true;
      }

      print('Updated categoryOptions: $categoryOptions');
    });
  }

  // 카테고리 모두 선택 또는 해제 함수
  void _toggleSelectAll(bool isSelected) {
    setState(() {
      categoryOptions.updateAll((key, value) => isSelected);

      if (isSelected) {
        selectedCategories = ['모두']; // 모두 선택 시 다른 카테고리는 선택되지 않음
      } else {
        selectedCategories.clear(); // 모두 해제 시 모든 선택 해제
      }
    });
  }

  // 체크박스 상태 변경 시 처리 함수
  void _onCategoryChanged(String category, bool? isSelected) {
    setState(() {
      if (category == '모두') {
        _toggleSelectAll(isSelected ?? false); // '모두' 카테고리 선택 시 모든 카테고리 선택/해제
      } else {
        categoryOptions[category] =
            isSelected ?? false; // 다른 카테고리 선택 시 해당 카테고리의 상태를 업데이트

        if (isSelected == false ) {
          // '모두'가 선택된 상태에서 다른 카테고리가 선택해제되면 '모두'를 해제
          if (selectedCategories.length <= 1) {
            // 선택된 카테고리가 1개 이하일 때 선택 해제를 막음
            print('카테고리는 하나 이상 선택해야 합니다.');
            categoryOptions[category] = true;  // 선택 해제를 방지
            return;
          }
          categoryOptions['모두'] = false;
          selectedCategories.remove(category); // 선택된 카테고리를 추가
          print('1selectedCategories ${category} ${selectedCategories}');
        } else {
          if (category != '모두') {
            selectedCategories.add(category); // 선택 해제 시 리스트에서 제거
          }
          print('2selectedCategories ${category}  ${selectedCategories}');
        }

        if (selectedCategories.length == categoryOptions.length - 1) {
          // '모두'를 제외한 카테고리 갯수 비교
          categoryOptions['모두'] = true;
        } else {
          categoryOptions['모두'] = false;
        }

        if (selectedCategories.isEmpty) {
          categoryOptions['모두'] = false;
        }

        // if (selectedCategories == null || selectedCategories!.isEmpty) {
        //   selectedCategories = ['모두'];
        // }
      }
    });
    print('3selectedCategories ${selectedCategories}');
  }

  // 날짜 선택 다이얼로그
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate =
        isStart ? DateTime.now() : startDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStart ? startDate : endDate)) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _saveSearchSettingsToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedCategories', selectedCategories ?? ['']);
    await prefs.setString(
        'startDate', startDate != null ? startDate!.toIso8601String() : '');
    await prefs.setString(
        'endDate', endDate != null ? endDate!.toIso8601String() : '');
    await prefs.setString('selectedPeriod', selectedPeriod ?? '');
  }

  @override
  Widget build(BuildContext context) {
    print('categoryOptions ${categoryOptions}');
    print('categoryOptions.entries ${categoryOptions.entries}');
    return Scaffold(
      appBar: AppBar(
        title: Text('기록 검색 상세설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 레시피 출처 선택
            Text(
              '카테고리 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: categoryOptions.entries.map((entry) {
                final category = entry.key;
                final isSelected = entry.value;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    _onCategoryChanged(category, selected);
                  },
                  selectedColor: Colors.deepPurple[100],
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
            // Column(
            //   children: categoryOptions.keys.map((String category) {
            //     return CheckboxListTile(
            //       title: Text(category),
            //       value: categoryOptions[category],
            //       onChanged: (bool? isSelected) {
            //         _onCategoryChanged(category, isSelected);
            //       },
            //     );
            //   }).toList(),
            // ),
            SizedBox(height: 16),

            // 제외 검색어 선택
            Text(
              '기간 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: periods.map((String period) {
                return Expanded(
                  child: RadioListTile<String>(
                    title: Text(period),
                    value: period,
                    groupValue: selectedPeriod,
                    onChanged: (String? value) {
                      setState(() {
                        selectedPeriod = value;
                        // 선택된 기간에 따라 시작 날짜와 끝 날짜 설정
                        DateTime now = DateTime.now();
                        switch (value) {
                          case '사용자 지정':
                            startDate = now;
                            endDate = now;
                            break;
                          case '1주':
                            startDate = now.subtract(Duration(days: 7));
                            endDate = now;
                            break;
                          case '1달':
                            startDate =
                                DateTime(now.year, now.month - 1, now.day);
                            endDate = now;
                            break;
                          case '3달':
                            startDate =
                                DateTime(now.year, now.month - 3, now.day);
                            endDate = now;
                            break;
                          case '1년':
                            startDate =
                                DateTime(now.year - 1, now.month, now.day);
                            endDate = now;
                            break;
                          default:
                            startDate = null;
                            endDate = null;
                        }
                      });
                    },
                    visualDensity: VisualDensity(horizontal: -3.0), // 수평 간격 줄이기
                    contentPadding: EdgeInsets.zero, // 패딩을 제거하여 간격 최소화
                  ),
                );
              }).toList(),
            ),
// 시작 날짜 선택
            Row(
              children: [
                Expanded(
                  child: Text(
                    '시작 날짜',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    '끝 날짜',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    startDate != null
                        ? DateFormat('yyyy-MM-dd').format(startDate!)
                        : '날짜를 선택하세요',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, true),
                  ),
                ),
                // 끝 날짜 선택
                Expanded(
                  child: Text(
                    endDate != null
                        ? DateFormat('yyyy-MM-dd').format(endDate!)
                        : '날짜를 선택하세요',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: NavbarButton(
            buttonTitle: '저장',
            onPressed: () async {
              await _saveSearchSettingsToLocal(); // 설정을 로컬에 저장
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}

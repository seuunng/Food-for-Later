import 'package:flutter/material.dart';
import 'package:food_for_later/components/navbar_button.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';
import 'package:intl/intl.dart';

class RecordSearchSettings extends StatefulWidget {
  @override
  _RecordSearchSettingsState createState() => _RecordSearchSettingsState();
}

class _RecordSearchSettingsState extends State<RecordSearchSettings> {
  String? selectedCategory;
  String? selectedPeriod;
  DateTime? startDate;
  DateTime? endDate;

  Map<String, bool> categoryOptions = {
    '모두': true,
    '식단': true,
    '운동': true,
    '자기개발': true,
    '기타': true,
  };

  List<String> periods = ['1달', '3달', '1년'];

  // 카테고리 모두 선택 또는 해제 함수
  void _toggleSelectAll(bool isSelected) {
    setState(() {
      categoryOptions.updateAll((key, value) => isSelected);
    });
  }

  // 체크박스 상태 변경 시 처리 함수
  void _onCategoryChanged(String category, bool? isSelected) {
    if (category == '모두') {
      _toggleSelectAll(isSelected ?? false);
    } else {
      setState(() {
        categoryOptions[category] = isSelected ?? false;

        // '모두' 옵션을 체크하려면 모든 개별 항목이 선택된 상태여야 함
        if (categoryOptions.values.every((selected) => selected)) {
          categoryOptions['모두'] = true;
        } else {
          categoryOptions['모두'] = false;
        }
      });
    }
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

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('추가하기 버튼 클릭됨')),
              );
            },
          ),
        ),
      ),
    );
  }
}

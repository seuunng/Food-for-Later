import 'package:flutter/material.dart';
import 'package:food_for_later/screens/foods/manage_categories.dart';

class AppUsageSettings extends StatefulWidget {
  @override
  _AppUsageSettingsState createState() => _AppUsageSettingsState();
}

class _AppUsageSettingsState extends State<AppUsageSettings> {
  String _selectedCategory_fridge = '기본 냉장고'; // 기본 선택값
  final List<String> _categories_fridge = ['기본 냉장고', '김치 냉장고']; // 카테고리 리스트
  String _selectedCategory_fridgeCategory = '냉장'; // 기본 선택값
  final List<String> _categories_fridgeCategory = ['냉장', '냉동', '상온']; // 카테고리 리스트
  String _selectedCategory_foods = '입고일 기준'; // 기본 선택값
  final List<String> _categories_foods = ['소비기한 기준', '입고일 기준']; // 카테고리 리스트
  String _selectedCategory_records = '앨범형'; // 기본 선택값
  final List<String> _categories_records = ['앨범형', '달력형', '목록형']; // 카테고리 리스트

  void _saveSettings() {
    // 저장할 데이터를 여기서 처리
    print('Fridge: $_selectedCategory_fridge');
    print('Fridge Category: $_selectedCategory_fridgeCategory');
    print('Foods: $_selectedCategory_foods');
    print('Records: $_selectedCategory_records');

    // 저장 후 메인 페이지로 이동
    Navigator.pop(context); // 이전 화면(메인 페이지)으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('어플 사용 설정'),
      ),
      body: ListView(
        children: [
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                '냉장고 선택',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCategory_fridge,
                  isExpanded: true, // 드롭다운이 화면 너비에 맞게 확장되도록 설정
                  items: _categories_fridge.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory_fridge = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                '냉장고 카테고리 선택',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCategory_fridgeCategory,
                  isExpanded: true, // 드롭다운이 화면 너비에 맞게 확장되도록 설정
                  items: _categories_fridgeCategory.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory_fridgeCategory = newValue!;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                '식품 상태관리 선택',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCategory_foods,
                  isExpanded: true, // 드롭다운이 화면 너비에 맞게 확장되도록 설정
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
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                '선호 식품 카테고리 수정',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageCategories()), // 계정 정보 페이지로 이동
                  );
                },
                child: Text('수정'),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                '조리방법 카테고리 수정',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageCategories()), // 계정 정보 페이지로 이동
                  );
                },
                child: Text('수정'),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                '대표 기록유형 선택',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCategory_records,
                  isExpanded: true, // 드롭다운이 화면 너비에 맞게 확장되도록 설정
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
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _saveSettings,
          child: Text('저장'),
        ),
      ),
    );
  }
}

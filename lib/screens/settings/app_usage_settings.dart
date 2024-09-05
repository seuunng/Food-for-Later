import 'package:flutter/material.dart';

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
  final List<String> _categories_foods = ['식품별 소비기한 기준', '입고일 기준']; // 카테고리 리스트
  String _selectedCategory_records = '앨범형'; // 기본 선택값
  final List<String> _categories_records = ['앨범형', '달력형', '목록형']; // 카테고리 리스트

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('어플 사용 설정'),
      ),
      body: Column(
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
                  // 로그아웃 로직 추가
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
                  // 로그아웃 로직 추가
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
    );
  }
}

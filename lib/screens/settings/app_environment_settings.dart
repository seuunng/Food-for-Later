import 'package:flutter/material.dart';

class AppEnvironmentSettings extends StatefulWidget {
  @override
  _AppEnvironmentSettingsState createState() => _AppEnvironmentSettingsState();
}

class _AppEnvironmentSettingsState extends State<AppEnvironmentSettings> {
  // 드롭다운 선택을 위한 변수
  String _selectedCategory_them = 'Light'; // 기본 선택값
  final List<String> _categories_them = ['Light', 'Dark']; // 카테고리 리스트
  String _selectedCategory_font = 'Arial'; // 기본 선택값
  final List<String> _categories_font = ['Arial', 'Roboto', 'Times New Roman']; // 카테고리 리스트

  void _saveSettings() {
    // 저장할 데이터를 여기서 처리
    print('Fridge: $_selectedCategory_them');
    print('Fridge Category: $_selectedCategory_font');

    // 저장 후 메인 페이지로 이동
    Navigator.pop(context); // 이전 화면(메인 페이지)으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('어플 환경 설정'),
      ),
      body: ListView(
        children: [
          // 드롭다운 카테고리 선택
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                '테마',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCategory_them,
                  isExpanded: true, // 드롭다운이 화면 너비에 맞게 확장되도록 설정
                  items: _categories_them.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory_them = newValue!;
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
                '폰트',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCategory_font,
                  isExpanded: true, // 드롭다운이 화면 너비에 맞게 확장되도록 설정
                  items: _categories_font.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory_font = newValue!;
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

import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';

class RecipeSearchSettings extends StatefulWidget {
  @override
  _RecipeSearchSettingsState createState() => _RecipeSearchSettingsState();
}

class _RecipeSearchSettingsState extends State<RecipeSearchSettings> {
  List<String> selectedSources = [];
  List<String> selectedcookingMethods = [];
  List<String> selectedcookingTools = [];

  TextEditingController excludeKeywordController = TextEditingController();

  List<String> sources = ['인터넷', '책', '"이따 뭐 먹지" 레시피', '기타'];
  List<String> cookingMethods = ['굽기', '튀기기', '끓이기', '찜'];
  List<String> cookingTools = ['오븐', '프라이팬', '냄비', '찜기'];

  List<String> excludeKeywords = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피 검색 상세설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 조리 도구 선택
            Text(
              '조리 도구 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: cookingTools.map((item) {
                final isSelected = selectedcookingTools.contains(item);
                return ChoiceChip(
                  label: Text(item),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedcookingTools.add(item);
                      } else {
                        selectedcookingTools.remove(item);
                      }
                    });
                  },
                  selectedColor: Colors.deepPurple[100],
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              '조리 방법 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: cookingMethods.map((item) {
                final isSelected = selectedcookingMethods.contains(item);
                return ChoiceChip(
                  label: Text(item),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedcookingMethods.add(item);
                      } else {
                        selectedcookingMethods.remove(item);
                      }
                    });
                  },
                  selectedColor: Colors.deepPurple[100],
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            // 레시피 출처 선택
            Text(
              '레시피 출처 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: sources.map((source) {
                final isSelected = selectedSources.contains(source);
                return ChoiceChip(
                  label: Text(source),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        selectedSources.add(source);
                      } else {
                        selectedSources.remove(source);
                      }
                    });
                  },
                  selectedColor: Colors.deepPurple[100],
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // 제외 검색어 선택
            Text(
              '제외 검색어 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: excludeKeywordController,
              decoration: InputDecoration(
                hintText: '제외할 검색어를 입력하세요',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _addExcludeKeyword();
                  },
                ),
              ),
              onSubmitted: (value) {
                _addExcludeKeyword();
              },
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: excludeKeywords.map((keyword) {
                return Chip(
                  label: Text(keyword),
                  onDeleted: () {
                    setState(() {
                      excludeKeywords.remove(keyword);
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50, // 버튼 높이 설정
          child: ElevatedButton(
            onPressed: () {
            },
            child: Text('설정 저장'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              textStyle: TextStyle(
                fontSize: 16, // 글씨 크기 조정
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2, //
              ),
            ),
          ),
        ),
      ),
    );
  }
// 제외 검색어 추가 함수
  void _addExcludeKeyword() {
    final keyword = excludeKeywordController.text.trim();
    if (keyword.isNotEmpty && !excludeKeywords.contains(keyword)) {
      setState(() {
        excludeKeywords.add(keyword);
      });
      excludeKeywordController.clear();
    }
  }
}

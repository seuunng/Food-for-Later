import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';

class RecordSearchSettings extends StatefulWidget {
  @override
  _RecordSearchSettingsState createState() => _RecordSearchSettingsState();
}

class _RecordSearchSettingsState extends State<RecordSearchSettings> {
  String? selectedSource;
  String? selectedCookingMethod;
  String? selectedCookingTool;
  TextEditingController excludeKeywordController = TextEditingController();

  List<String> sources = ['인터넷', '책', '직접 만든 레시피', '기타'];
  List<String> cookingMethods = ['굽기', '튀기기', '끓이기', '찜'];
  List<String> cookingTools = ['오븐', '프라이팬', '냄비', '찜기'];

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
            // 레시피 출처 선택
            Text(
              '레시피 출처 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedSource,
              hint: Text('출처를 선택하세요'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSource = newValue;
                });
              },
              items: sources.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
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
              ),
            ),
            SizedBox(height: 16),

            // 조리 방법 선택
            Text(
              '조리 방법 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedCookingMethod,
              hint: Text('조리 방법을 선택하세요'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCookingMethod = newValue;
                });
              },
              items: cookingMethods.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // 조리 도구 선택
            Text(
              '조리 도구 선택',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: selectedCookingTool,
              hint: Text('조리 도구를 선택하세요'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCookingTool = newValue;
                });
              },
              items: cookingTools.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // 추가 버튼 (옵션)
            Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text('설정 저장'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15), // 위아래 패딩을 조정하여 버튼 높이 축소
                    // backgroundColor: isDeleteMode ? Colors.red : Colors.blueAccent, // 삭제 모드일 때 빨간색, 아닐 때 파란색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게
                    ),
                    elevation: 5,
                    textStyle: TextStyle(
                      fontSize: 18, // 글씨 크기 조정
                      fontWeight: FontWeight.w500, // 약간 굵은 글씨체
                      letterSpacing: 1.2, //
                    ),
                    // primary: isDeleteMode ? Colors.red : Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

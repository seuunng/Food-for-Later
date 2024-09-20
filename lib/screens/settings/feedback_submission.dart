import 'package:flutter/material.dart';

class FeedbackSubmission extends StatefulWidget {
  @override
  _FeedbackSubmissionState createState() => _FeedbackSubmissionState();
}

class _FeedbackSubmissionState extends State<FeedbackSubmission> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

// 드롭다운 선택을 위한 변수
  String _selectedCategory = '일반'; // 기본 카테고리
  final List<String> _categories = ['일반', '버그 신고', '기능 요청', '기타'];

  // 의견 제출 함수
  void _submitFeedback() {
    String title = _titleController.text;
    String content = _contentController.text;

    // 입력값을 처리하는 로직을 여기에 추가 (예: 서버로 전송 또는 로컬 저장)
    if (title.isNotEmpty && content.isNotEmpty) {
      print('Title: $title');
      print('Content: $content');

      // 입력 후 초기화 및 메시지 보여주기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('의견이 성공적으로 전송되었습니다!')),
      );
      _titleController.clear();
      _contentController.clear();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목과 내용을 모두 입력해주세요!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('의견보내기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 드롭다운 카테고리 선택
            Row(
              children: [
                Text(
                  '구분',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(), // 텍스트와 드롭다운 사이 간격
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true, // 드롭다운이 화면 너비에 맞게 확장되도록 설정
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            Text(
              '제목',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목을 입력하세요',
              ),
            ),
            SizedBox(height: 16),
            Text(
              '내용',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요',
              ),
              maxLines: 5, // 여러 줄 입력 가능
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _submitFeedback,
            child: Text('의견 보내기'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15), // 위아래 패딩을 조정하여 버튼 높이 축소
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게
              ),
              elevation: 5,
              textStyle: TextStyle(
                fontSize: 18, // 글씨 크기 조정
                fontWeight: FontWeight.w500, // 약간 굵은 글씨체
                letterSpacing: 1.2, //
              ),
            ),
          ),
        ),
    );
  }
}

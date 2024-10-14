import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';

class ReportAnIssue extends StatefulWidget {
  final int postNo; // 게시물 제목정보

  ReportAnIssue({required this.postNo});
  @override
  _ReportAnIssueState createState() => _ReportAnIssueState();
}

class _ReportAnIssueState extends State<ReportAnIssue> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String userId = '현재 유저아이디';

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  // 드롭다운 선택을 위한 변수
  String _selectedCategory = '일반'; // 기본 카테고리
  final List<String> _categories = ['일반', '버그 신고', '기능 요청', '기타'];

  // 의견 제출 함수
  void _submitFeedback() async {
    String title = _titleController.text;
    String content = _contentController.text;

    // 입력값을 처리하는 로직을 여기에 추가 (예: 서버로 전송 또는 로컬 저장)
    if (title.isNotEmpty && content.isNotEmpty) {
      try {
        // Firestore에 데이터 저장
        await _db.collection('feedback').add({
          'title': title,
          'content': content,
          'category': _selectedCategory,
          'timestamp': FieldValue.serverTimestamp(), // 서버 시간을 저장
          'postType': widget.postNo,
          'postNo': widget.postNo,
          'author': userId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('의견이 성공적으로 전송되었습니다!')),
        );

        _titleController.clear();
        _contentController.clear();
        Navigator.pop(context);
      } catch (e) {
        // 오류 발생 시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('의견 전송 중 오류가 발생했습니다. 다시 시도해주세요.')),
        );
      }
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
        title: Text('신고하기'),
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
            Row(
              children: [
                Text(
                  '게시물유형',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                ),
                Spacer(),
                Text(
                  widget.postNo.toString(),
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Spacer(),
                Text(
                  '게시물번호',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                ),
                Spacer(),
                Text(
                  widget.postNo.toString(),
                  style: TextStyle(
                    fontSize: 18,
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
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitFeedback,
            child: Text('의견 보내기'),
            style: ElevatedButton.styleFrom(
              padding:
                  EdgeInsets.symmetric(vertical: 15), // 위아래 패딩을 조정하여 버튼 높이 축소
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
    );
  }
}

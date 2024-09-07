import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String author;
  final String authorEmail;
  final DateTime createdDate;
  final List<String> statusOptions;

  FeedbackDetailPage({
    required this.title,
    required this.author,
    required this.authorEmail,
    required this.content,
    required this.createdDate,
    required this.statusOptions,
  });
  void _saveSettings(BuildContext context) {
    // 저장 후 메인 페이지로 이동
    Navigator.pop(context); // 이전 화면(메인 페이지)으로 돌아가기
  }
  Future<void> _sendEmail(String email) async {
    final String subject = Uri.encodeComponent('의견 처리 안내');
    final String body = Uri.encodeComponent('안녕하세요. "이따 뭐 먹지" 어플을 사랑해주시고 관심가져주셔서 감사합니다. 보내주신 소중한 의견을 잘 확인하였습니다. 신속하게 처리하고 처리결과 안내드리겠습니다.');

    final String emailUrl = 'mailto:$email?subject=$subject&body=$body';

    try {
      if (await canLaunch(emailUrl)) {
        await launch(emailUrl);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      print(e);  // 오류 메시지 출력
    }
  }
  @override
  Widget build(BuildContext context) {
    String selectedStatus = statusOptions.first;
    return Scaffold(
      appBar: AppBar(
        title: Text('의견 상세보기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$title',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Spacer(),
                Text('${createdDate.toLocal().toString().split(' ')[0]} '),
                Text(' $author '),
                GestureDetector(
                  onTap: () {
                    _sendEmail('$authorEmail');  // 이메일 보내기 함수 호출
                  },
                  child: Text(' $authorEmail',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(content),
            SizedBox(height: 20),
            Text(
              '확인사항:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  '처리 결과:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                DropdownButton<String>(
                  value: selectedStatus,
                  onChanged: (String? newValue) {
                    // Handle dropdown value change
                    selectedStatus = newValue!;
                  },
                  items: statusOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () => _saveSettings(context),
          child: Text('저장'),
        ),
      ),
    );
  }
}

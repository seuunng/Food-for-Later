import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackDetailPage extends StatefulWidget {
  final String feedbackId;  // Firestore에서 해당 피드백 문서 ID
  final String title;
  final String content;
  final String author;
  final String authorEmail;
  final DateTime createdDate;
  final List<String> statusOptions;
  final String postType;
  final String postNo;
  final String confirmationNote;
  final String selectedStatus;

  FeedbackDetailPage({
    required this.feedbackId,  // feedback 문서 ID를 받아서 업데이트에 사용
    required this.title,
    required this.author,
    required this.authorEmail,
    required this.content,
    required this.createdDate,
    required this.statusOptions,
    required this.postType,
    required this.postNo,
    required this.confirmationNote,
    required this.selectedStatus,
  });

  @override
  _FeedbackDetailPageState createState() => _FeedbackDetailPageState();
}

class _FeedbackDetailPageState extends State<FeedbackDetailPage> {
  late String confirmationNote; // 상태로 관리될 확인사항 변수
  late String selectedStatus; // 상태로 관리될 처리 결과 변수
  late TextEditingController _confirmationController; // TextEditingController 선언


  @override
  void initState() {
    super.initState();
    confirmationNote = widget.confirmationNote;
    selectedStatus = widget.selectedStatus;
    _confirmationController = TextEditingController(text: widget.confirmationNote);
    print('status ${widget.selectedStatus}');
    print('statusOptions ${widget.statusOptions}');
  }
  @override
  void dispose() {
    _confirmationController.dispose(); // 메모리 누수를 방지하기 위해 dispose
    super.dispose();
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

  Future<void> _saveSettings(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('feedback')  // feedback 컬렉션 참조
          .doc(widget.feedbackId)  // 문서 ID로 참조
          .update({
        'confirmationNote': confirmationNote,  // 확인사항
        'status': selectedStatus,  // 처리결과
      });

      // 저장 성공 후 화면 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장되었습니다.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('Error updating feedback: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Spacer(),
                Text(widget.createdDate.toLocal().toString().split(' ')[0]),
                SizedBox(width: 10),
                Text(widget.author),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    _sendEmail(widget.authorEmail);  // 이메일 보내기 함수 호출
                  },
                  child: Text(widget.authorEmail,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Spacer(),
                Text(
                  '게시물유형',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 10),
                Text(
                  widget.postType.toString(),
                ),
                SizedBox(width: 10),
                Text(
                  '게시물번호',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                SizedBox(width: 10),
                Text(
                  widget.postNo.toString(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(widget.content),
            SizedBox(height: 20),
            Text(
              '확인사항',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _confirmationController, // Controller를 사용하여 초기 값 설정
              onChanged: (value) {
                setState(() {
                  confirmationNote = value; // 확인사항 업데이트
                });
              },
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  '처리 결과',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                DropdownButton<String>(
                  value: widget.statusOptions.contains(selectedStatus) ? selectedStatus : null,  // selectedStatus가 statusOptions에 있는지 확인
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedStatus = newValue;
                        print(newValue);// 선택한 값을 selectedStatus에 저장
                      });
                    }
                  },
                  items: widget.statusOptions.toSet().map<DropdownMenuItem<String>>((String value) {
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

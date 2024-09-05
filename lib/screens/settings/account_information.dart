import 'package:flutter/material.dart';

class AccountInformation extends StatefulWidget {
  @override
  _AccountInformationState createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  String _nickname = '사용자 닉네임'; // 닉네임 기본값
  String _email = 'user@example.com'; // 이메일 기본값

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계정 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 닉네임 정보
            Text(
              '닉네임 ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                Spacer(),
                Text(
                  _nickname,
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // 로그아웃 로직 추가
                    _showNicknameChangeDialog();
                  },
                  child: Text('수정'),
                ),
              ],
            ),
            // 이메일 정보
            Text(
              '이메일 ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                Spacer(),
                Text(
                  _email,
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                SizedBox(width: 70, height: 50,)
              ],
            ),
            Text(
              '비밀번호 ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Spacer(),
                // 비밀번호 변경 버튼
                ElevatedButton(
                  onPressed: () {
                    // 비밀번호 변경 로직 추가
                    _showPasswordSendDialog();
                  },
                  child: Text('수정'),
                ),
              ],
            ),
            Row(
              children: [
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // 로그아웃 로직 추가
                    _logout();
                  },
                  child: Text('회원탈퇴'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // 로그아웃 로직 추가
                    _logout();
                  },
                  child: Text('로그아웃'),
                ),
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 비밀번호 변경 다이얼로그
  Future<void> _showPasswordSendDialog() async {
    TextEditingController _passwordController = TextEditingController();
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('임의의 비밀번호 받기'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('임시비밀번호 보내기'),
              onPressed: () {
                // 비밀번호 변경 로직 처리
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _showNicknameChangeDialog() async {
    TextEditingController _passwordController = TextEditingController();
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('닉네임 변경'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: '새 닉네임을 입력하세요'),
          ),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('변경'),
              onPressed: () {
                // 비밀번호 변경 로직 처리
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
  // 로그아웃 처리
  void _logout() {
    // 로그아웃 로직 (예: Firebase Auth 사용시)
    // Navigator.popUntil(context, ModalRoute.withName('/login'));
  }
}

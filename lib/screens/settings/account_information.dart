import 'package:flutter/material.dart';
import 'package:food_for_later/components/navbar_button.dart';

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
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15), // 위아래 패딩을 조정하여 버튼 높이 축소
                    // backgroundColor: isDeleteMode ? Colors.red : Colors.blueAccent, // 삭제 모드일 때 빨간색, 아닐 때 파란색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게
                    ),
                  ),
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
                SizedBox(
                  width: 70,
                  height: 50,
                )
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
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15), // 위아래 패딩을 조정하여 버튼 높이 축소
                    // backgroundColor: isDeleteMode ? Colors.red : Colors.blueAccent, // 삭제 모드일 때 빨간색, 아닐 때 파란색
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게
                    ),
                  ),
                ),
              ],
            ),

            // Row(
            //   children: [
            //     Spacer(),
            //     ElevatedButton(
            //       onPressed: () {
            //         _withdrawAlertDialog();
            //       },
            //       child: Text('회원탈퇴'),
            //     ),
            //     SizedBox(width: 10),
            //     ElevatedButton(
            //       onPressed: () {
            //         _logoutAlertDialog();
            //       },
            //       child: Text('로그아웃'),
            //     ),
            //     Spacer(),
            //   ],
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 버튼 사이 간격을 균등하게 설정
          children: [
            Expanded(
              child: NavbarButton(
                buttonTitle: '회원탈퇴',
                onPressed: () { // 람다식으로 함수 전달
                  _withdrawAlertDialog();
                },
              ),
            ),
            SizedBox(width: 20), // 두 버튼 사이 간격
            Expanded(
              child:
              NavbarButton(
                buttonTitle: '로그아웃',
                onPressed: () { // 람다식으로 함수 전달
                  _logoutAlertDialog();
                },
              ),
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
          title: Text('비밀번호 보내기'),
          content: Text('임의의 비밀번호를 등록된 이메일로 보냅니다.'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('보내기'),
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
  void _logoutAlertDialog() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃을 진행할까요?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('로그아웃'),
              onPressed: () {
                // 로그아웃 로직 처리
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _withdrawAlertDialog() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('탈퇴를 진행할까요?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('탈퇴'),
              onPressed: () {
                // 회원탈퇴 로직 처리
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

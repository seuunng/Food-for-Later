import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';

class AdminLogin extends StatefulWidget {
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _passwordController = TextEditingController();

  // 비밀번호 확인 함수
  void _handleSubmit() {
    String password = _passwordController.text;
    // 비밀번호 처리 로직 (예: 비밀번호 확인)
    if (password == '1111') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminMainPage()), // 다음 페이지로 이동
      );
    } else {
      // 비밀번호가 틀렸을 때 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 올바르지 않습니다.')),
      );
      // 추가 로직 구현 (로그인 처리 등)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자 페이지 로그인'),
      ),
      body: Center(
        // 수직과 수평 모두 중앙 정렬
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0), // 양쪽에 여백 추가
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 배치
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true, // 비밀번호 입력시 텍스트를 숨김 처리
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력하세요',
                  border: OutlineInputBorder(), // 테두리 추가
                ),
                onSubmitted: (value) {
                  _handleSubmit(); // 엔터키를 누르면 호출되는 함수
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

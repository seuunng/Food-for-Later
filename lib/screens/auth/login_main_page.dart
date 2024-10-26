import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> signInWithEmailAndPassword() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home'); // 홈으로 이동
    } catch (e) {
      setState(() {
        errorMessage = '로그인 실패: ${e.toString()}';
      });
    }
  }

  Future<void> registerWithEmailAndPassword() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home'); // 홈으로 이동
    } catch (e) {
      setState(() {
        errorMessage = '회원가입 실패: ${e.toString()}';
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // TextField(
            //   controller: _nickNameController,
            //   decoration: InputDecoration(labelText: '닉네임'),
            // ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 12),
            Text(errorMessage, style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: signInWithEmailAndPassword,
              child: Text('로그인'),
            ),
            TextButton(
              onPressed: registerWithEmailAndPassword,
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}

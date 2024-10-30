import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/components/basic_elevated_button.dart';
import 'package:food_for_later/components/login_elevated_button.dart';
import 'package:food_for_later/components/navbar_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';

  bool _validateInputs() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        errorMessage = '이메일과 비밀번호를 모두 입력해주세요.';
      });
      return false;
    }
    return true;
  }

  Future<void> signInWithEmailAndPassword() async {
    if (!_validateInputs()) return;
    try {
      // Firebase의 이메일/비밀번호 인증
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // 로그인 성공 시 홈 화면으로 이동
      if (result.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // 사용자 정보가 없을 경우 오류 메시지 표시
        setState(() {
          errorMessage = '로그인 실패: 사용자 정보를 가져올 수 없습니다.';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = '로그인 실패: ${e.code} - ${e.message}';
      });
      print('로그인 실패: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        errorMessage = '로그인 실패: 알 수 없는 오류 - ${e.toString()}';
      });
      print('로그인 실패: 알 수 없는 오류 - ${e.toString()}');
    }
  }

  Future<void> registerWithEmailAndPassword() async {
    if (!_validateInputs()) return;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacementNamed(context, '/home'); // 홈으로 이동
    } on FirebaseAuthException catch (e) {
      // FirebaseAuthException 별 오류 처리
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = '이미 사용 중인 이메일입니다.';
          break;
        case 'invalid-email':
          errorMessage = '잘못된 이메일 형식입니다.';
          break;
        case 'weak-password':
          errorMessage = '비밀번호는 6자리 이상이어야 합니다.';
          break;
        default:
          errorMessage = '회원가입 실패: ${e.message}';
      }
      setState(() {});
      print('회원가입 실패: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        errorMessage = '회원가입 실패: ${e.toString()}';
      });
      print('회원가입 실패: ${e.toString()}');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 로그인 취소됨
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 사용자 인증
      await _auth.signInWithCredential(credential);
      Navigator.pushReplacementNamed(context, '/home'); // 홈으로 이동
    } catch (e) {
      setState(() {
        errorMessage = 'Google 로그인 실패: ${e.toString()}';
      });
      print('Google 로그인 실패: $e');
    }
  }

  Future<void> signInWithKakao() async {
    try {
      // Kakao 로그인
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;

      print('isInstalled $isInstalled');

      if (isInstalled) {
        token = await UserApi.instance.loginWithKakaoTalk();

        print('token $token');

      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      // Kakao Access Token으로 Firebase Custom Token 생성 및 로그인
      final kakaoAccessToken = token.accessToken;
      print('kakaoAccessToken $kakaoAccessToken');

      // Firebase 서버에서 Kakao Token을 통해 Custom Token을 생성하는 로직 필요
      final firebaseCustomToken = await createFirebaseToken(kakaoAccessToken);
      print('firebaseCustomToken $firebaseCustomToken');
      // Firebase 로그인
      await _auth.signInWithCustomToken(firebaseCustomToken);
      Navigator.pushReplacementNamed(context, '/home'); // 홈으로 이동

    } catch (e) {
      print('카카오 로그인 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카카오 로그인에 실패했습니다.')),
      );
    }
  }

  Future<String> createFirebaseToken(String kakaoAccessToken) async {
    final uri = Uri.parse('https://us-central1-food-for-later.cloudfunctions.net/createFirebaseToken'); // 백엔드 서버의 엔드포인트
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'kakaoAccessToken': kakaoAccessToken}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('firebaseCustomToken $data');
      return data['firebaseCustomToken'];
    } else {
      print('Firebase Function Error: ${response.body}');
      throw Exception('Failed to generate Firebase Custom Token');
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
            // Row(
            //   children: [
            // SizedBox(width: 10,),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일'),
            ),
            // SizedBox(width: 10,),
            //   ],
            // ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 12),
            // Text(errorMessage, style: TextStyle(color: Colors.red)),
            BasicElevatedButton(
              onPressed: signInWithEmailAndPassword,
              iconTitle: Icons.login,
              buttonTitle: '로그인',
            ),
            TextButton(
              onPressed: registerWithEmailAndPassword,
              child: Text('회원가입'),
            ),
            Divider(),
            SizedBox(height: 20),
            LoginElevatedButton(
              buttonTitle: 'Google로 로그인',
              image: 'assets/images/google_logo.png',
              onPressed: signInWithGoogle,
            ),
            SizedBox(height: 12),
            LoginElevatedButton(
              buttonTitle: 'Kakao Talk으로 로그인',
              image: 'assets/images/kakao_talk_logo.png',
              onPressed: signInWithKakao,
            ),
            SizedBox(height: 12),
            LoginElevatedButton(
              buttonTitle: 'Naver로 로그인',
              image: 'assets/images/naver_logo.png',
              onPressed: signInWithGoogle,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      }catch (e) {
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

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
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
            Divider(),
            ElevatedButton(
              onPressed: signInWithGoogle,
              child: Text('Google로 로그인'),
            ),
          ],
        ),
      ),
    );
  }
}

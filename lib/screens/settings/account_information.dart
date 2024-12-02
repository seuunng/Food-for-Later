import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_for_later/components/basic_elevated_button.dart';
import 'package:food_for_later/components/navbar_button.dart';
import 'package:food_for_later/firebase_service.dart';
import 'package:food_for_later/screens/auth/login_main_page.dart';
import 'package:http/http.dart' as http;

class AccountInformation extends StatefulWidget {
  @override
  _AccountInformationState createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  String _nickname = '사용자의 닉네임'; // 닉네임 기본값
  String _email = 'user@example.com'; // 이메일 기본값
  final TextEditingController _passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email ?? '이메일 없음';

        // 이메일 주소에서 @ 앞부분을 추출하여 닉네임으로 설정
        if (_email.contains('@')) {
          _nickname = _email.split('@')[0];
        } else {
          _nickname = '닉네임 없음'; // 기본 닉네임
        }
      });
    }
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // 최근 인증이 필요할 경우 재인증 수행
        await user.reauthenticateWithCredential(EmailAuthProvider.credential(
          email: user.email!,
          password: 'your_password_here', // 사용자가 입력한 비밀번호
        ));

        // 계정 삭제
        await user.delete();

        // 성공 메시지 및 로그아웃 후 로그인 페이지로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계정이 성공적으로 삭제되었습니다.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // 재인증이 필요한 경우의 오류 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('최근 로그인한 기록이 없어 다시 로그인해주세요.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('계정 삭제 중 오류가 발생했습니다: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('계정 삭제 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface),
            ),

            Row(
              children: [
                Spacer(),
                Text(
                  _nickname,
                  style: TextStyle(fontSize: 16,
                      color: theme.colorScheme.onSurface),
                ),
                Spacer(),
                BasicElevatedButton(
                  onPressed: () {
                    _showNicknameChangeDialog(); // 검색 버튼 클릭 시 검색어 필터링
                  },
                  iconTitle: Icons.edit,
                  buttonTitle: '수정',
                ),
              ],
            ),
            // 이메일 정보
            Text(
              '이메일 ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface),
            ),
            Row(
              children: [
                Spacer(),
                Text(
                  _email,
                  style: TextStyle(fontSize: 16,
                      color: theme.colorScheme.onSurface),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface),
            ),
            Row(
              children: [
                Spacer(),
                // 비밀번호 변경 버튼
                BasicElevatedButton(
                  onPressed: () {
                    _showPasswordSendDialog(); // 검색 버튼 클릭 시 검색어 필터링
                  },
                  iconTitle: Icons.edit,
                  buttonTitle: '수정',
                )
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
            // Expanded(
            //   child: NavbarButton(
            //     buttonTitle: '회원탈퇴',
            //     onPressed: () {
            //       // 람다식으로 함수 전달
            //       _withdrawAlertDialog();
            //     },
            //   ),
            // ),
            // SizedBox(width: 20), // 두 버튼 사이 간격
            Expanded(
              child: NavbarButton(
                buttonTitle: '로그아웃',
                onPressed: () {
                  // 람다식으로 함수 전달
                  _logoutAlertDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 새 비밀번호 이메일 전송 함수 예시 (실제 API나 SMTP 설정이 필요)
  Future<void> _sendEmailWithNewPassword(
      String email, String newPassword) async {
    // if (email.isEmpty) {
    //   print('Error: email is empty.');
    //   return; // 이메일이 비어 있다면 함수 종료
    // }
    final serviceId = 'service_ywv72ps';
    final templateId = 'template_sqijmdh';
    final userId = 'DS6fXKVLzGOG-3fAQ';
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    // EmailJS API로 요청할 데이터 정의
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'to_email': email,
          'message': '임시 비밀번호: ${newPassword}',
        },
      }),
    );

    if (response.statusCode == 200) {
      print('이메일 전송 성공');

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('email $email');
    } else {
      print('이메일 전송 실패: ${response.body}');
    }
  }

  // 비밀번호 변경 다이얼로그
  Future<void> _showPasswordSendDialog() async {
    final theme = Theme.of(context);
    // 랜덤 6자리 비밀번호 생성 함수
    String _generateRandomPassword(int length) {
      const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
      Random random = Random();
      return String.fromCharCodes(Iterable.generate(length,
          (_) => characters.codeUnitAt(random.nextInt(characters.length))));
    }

    String newPassword = _generateRandomPassword(6); // 6자리 비밀번호 생성
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('임시 비밀번호 보내기',

                style: TextStyle(color: theme.colorScheme.onSurface)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${user.email}로 전송합니다.'),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(hintText: '현재 비밀번호를 입력하세요'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('보내기'),
                onPressed: () async {
                  try {
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: _passwordController.text
                          .trim(), // 사용자가 입력한 현재 비밀번호로 설정
                    );
                    // 비밀번호 입력 확인
                    if (_passwordController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('현재 비밀번호를 입력해주세요.')),
                      );
                      return;
                    }
                    await user.reauthenticateWithCredential(credential);
                    await user.updatePassword(newPassword);
                    await _sendEmailWithNewPassword(user.email!, newPassword);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('비밀번호가 이메일로 전송되었습니다.')),
                      );
                      print('newPassword $newPassword');
                      Navigator.pop(context); // 다이얼로그 닫기
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'requires-recent-login') {
                      // 사용자에게 재로그인 요구
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('비밀번호 업데이트 실패: ${e.message}')),
                      );
                    }
                  } catch (e) {
                    print('비밀번호 업데이트 오류: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('비밀번호 업데이트 실패: $e')),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 상태를 확인할 수 없습니다.')),
      );
    }
  }

  Future<void> _showNicknameChangeDialog() async {
    final theme = Theme.of(context);
    TextEditingController _nickNameController = TextEditingController();
    User? user = FirebaseAuth.instance.currentUser;

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('닉네임 변경',
              style: TextStyle(color: theme.colorScheme.onSurface)),
          content: TextField(
            controller: _nickNameController,
            // obscureText: true,
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
              onPressed: () async {
                String newNickname = _nickNameController.text.trim();
                if (newNickname.isNotEmpty && user != null) {
                  // Firestore의 users 컬렉션에 닉네임 업데이트
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid) // 사용자 ID를 기준으로 문서 선택
                      .set({'nickname': newNickname}, SetOptions(merge: true));
                  // 로컬 상태 업데이트
                  setState(() {
                    _nickname = newNickname;
                  });
                  Navigator.pop(context); // 다이얼로그 닫기
                } else {
                  // 닉네임이 비어있으면 안내 메시지 추가 가능
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('닉네임을 입력해주세요')),
                  );
                }
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
              onPressed: () async {
                await recordSessionEnd(); // 세션 종료 기록
                await FirebaseAuth.instance.signOut(); // Firebase 로그아웃

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()), // 로그인 페이지로 이동
                  );
                });
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
              onPressed: () async {
                Navigator.pop(context);
                await _deleteAccount();
              },
            ),
          ],
        );
      },
    );
  }
}

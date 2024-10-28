import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/firebase_options.dart';
import 'package:food_for_later/screens/auth/login_main_page.dart';
import 'package:food_for_later/screens/fridge/fridge_main_page.dart';
import 'package:food_for_later/screens/home_screen.dart';
import 'firebase_options.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

//Flutter 앱의 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(MyApp());
}

// 앱 전체를 나타내는 루트 위젯
//StatelessWidget: 상태가 없는 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Flutter는 build() 메서드가 호출될 때마다 화면을 새로 그립니다.
    //MaterialApp: 기본적인 앱 구조를 제공하는 위젯
    return MaterialApp(
      title: '이따뭐먹지',
      theme: ThemeData(
        //themeData: 앱의 전반적인 테마를 정의
        primarySwatch: Colors.lightGreen,
      ),
      home: AuthStateWidget(), // HomeScreen을 메인 화면으로 설정
      routes: {
        '/home': (context) => HomeScreen(), // "/home" 경로 추가
        '/login': (context) => LoginPage(), // Login 경로도 추가 가능
      },
      navigatorObservers: [
        DeleteModeObserver(onPageChange: () {
          // 페이지가 변경될 때 실행할 로직 추가
        }),
        routeObserver, // 기존 routeObserver도 유지
      ],
    );
  }
}

class AuthStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomeScreen(); // 로그인된 사용자를 위한 홈 페이지
        } else {
          return LoginPage(); // 로그인 페이지로 이동
        }
      },
    );
  }
}

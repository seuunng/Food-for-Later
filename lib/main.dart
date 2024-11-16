import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food_for_later/firebase_options.dart';
import 'package:food_for_later/firebase_service.dart';
import 'package:food_for_later/providers/theme_provider.dart';
import 'package:food_for_later/screens/auth/login_main_page.dart';
import 'package:food_for_later/screens/fridge/fridge_main_page.dart';
import 'package:food_for_later/screens/home_screen.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

//Flutter 앱의 진입점
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  // await recordSessionStart();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String initialFont = prefs.getString('fontType') ?? 'Arial';
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String themeMode = prefs.getString('themeMode') ?? 'Light';
  KakaoSdk.init(nativeAppKey: 'cae77ccb2159f26f7234f6ccf269605e');
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(initialFont),
      child: MyApp(),
    ),
  );
}

// 앱 전체를 나타내는 루트 위젯
//StatelessWidget: 상태가 없는 위젯
class MyApp extends StatelessWidget {
  // final String themeMode;
  // MyApp({required this.themeMode});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    //Flutter는 build() 메서드가 호출될 때마다 화면을 새로 그립니다.
    //MaterialApp: 기본적인 앱 구조를 제공하는 위젯
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return MaterialApp(
        title: '이따뭐먹지',
        // theme: themeProvider.currentTheme,
        theme: themeProvider.themeData,
        home: AuthStateWidget(),
        // HomeScreen을 메인 화면으로 설정
        routes: {
          '/home': (context) => HomeScreen(), // "/home" 경로 추가
          '/login': (context) => LoginPage(), // Login 경로도 추가 가능
        },
        navigatorObservers: [
          DeleteModeObserver(onPageChange: () {

          }),
          routeObserver, // 기존 routeObserver도 유지
        ],
      );
    });
  }
}

class AuthStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
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

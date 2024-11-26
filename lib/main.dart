import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/firebase_options.dart';
import 'package:food_for_later/providers/theme_provider.dart';
import 'package:food_for_later/screens/auth/login_main_page.dart';
import 'package:food_for_later/screens/fridge/fridge_main_page.dart';
import 'package:food_for_later/screens/home_screen.dart';
import 'package:food_for_later/themes/custom_theme_mode.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

//Flutter 앱의 진입점
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print("Initializing Firebase...");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error during Firebase initialization: $e");
  }
  // await recordSessionStart();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String initialFont = prefs.getString('fontType') ?? 'NanumGothic';
  String themeModeStr = prefs.getString('themeMode') ?? 'light';
  CustomThemeMode initialThemeMode = CustomThemeMode.values.firstWhere(
        (mode) => mode.toString().split('.').last == themeModeStr,
    orElse: () => CustomThemeMode.light,
  );
  KakaoSdk.init(nativeAppKey: 'cae77ccb2159f26f7234f6ccf269605e');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(initialThemeMode, initialFont),
        ),
      ],
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

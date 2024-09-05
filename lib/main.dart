import 'package:flutter/material.dart';
import 'package:food_for_later/screens/home_screen.dart';

//Flutter 앱의 진입점
void main() {
  runApp(MyApp());
}
// 앱 전체를 나타내는 루트 위젯
//StatelessWidget: 상태가 없는 위젯
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) { //Flutter는 build() 메서드가 호출될 때마다 화면을 새로 그립니다.
    //MaterialApp: 기본적인 앱 구조를 제공하는 위젯
    return MaterialApp(
      title: '이따뭐먹지',
      theme: ThemeData(
        //themeData: 앱의 전반적인 테마를 정의
        primarySwatch: Colors.lightGreen,
      ),
      home: HomeScreen(),  // HomeScreen을 메인 화면으로 설정
    );
  }
}
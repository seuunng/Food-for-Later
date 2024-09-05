import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_login.dart';
import 'package:food_for_later/screens/fridge/fridge_main_page.dart';
import 'package:food_for_later/screens/recipe/recipe_main_page.dart';
import 'package:food_for_later/screens/records/records_calendar_view.dart';
import 'package:food_for_later/screens/settings/account_information.dart';
import 'package:food_for_later/screens/settings/app_environment_settings.dart';
import 'package:food_for_later/screens/settings/app_usage_settings.dart';
import 'package:food_for_later/screens/settings/feedback_submission.dart';
import 'package:food_for_later/screens/shpping_list/shopping_list_main_page.dart';

//StatefulWidget: 상태가 있는 위젯
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 각 페이지를 저장하는 리스트
  List<Widget> _pages = <Widget>[
    FridgeMainPage(), // 냉장고 페이지
    ShoppingListMainPage(), // 예시로 장보기 페이지
    RecipeMainPage(), // 예시로 레시피 페이지
    RecordsCalendarView(), // 예시로 기록 페이지
  ];

  void _onItemTapped(int index) {
    if (index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('이따뭐먹지'),
      ),
      drawer: Drawer(
          child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightGreen,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '설정',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('계정 정보'),
            onTap: () {
              Navigator.pop(context); // 사이드바 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountInformation()), // 계정 정보 페이지로 이동
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.system_security_update_good),
            title: Text('어플 사용 설정'),
            onTap: () {
              Navigator.pop(context); // 사이드바 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppUsageSettings()), // 계정 정보 페이지로 이동
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('어플 환경 설정'),
            onTap: () {
              Navigator.pop(context); // 사이드바 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppEnvironmentSettings()), // 계정 정보 페이지로 이동
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.send),
            title: Text('의견보내기'),
            onTap: () {
              Navigator.pop(context); // 사이드바 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackSubmission()), // 계정 정보 페이지로 이동
              );
            },
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('관리자 페이지'),
            onTap: () {
              Navigator.pop(context); // 사이드바 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminLogin()), // 계정 정보 페이지로 이동
              );
            },
          ),
        ],
      )),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // _pages 리스트에서 선택된 인덱스의 페이지를 표시
      ),

      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: '냉장고'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: '장보기'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: '레시피'),
          BottomNavigationBarItem(icon: Icon(Icons.drive_file_rename_outline_rounded), label: '기록'),
        ],
        currentIndex: _selectedIndex, // 현재 선택된 탭
        onTap: _onItemTapped, // 탭 선택시 호출될 함수
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_login.dart';
import 'package:food_for_later/screens/foods/add_item_to_category.dart';
import 'package:food_for_later/screens/foods/manage_categories.dart';
import 'package:food_for_later/screens/fridge/add_item.dart';
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
  static const List<String> basicFoodsCategories = [
    '육류',
    '수산물',
    '채소',
    '과일',
    '견과'
  ];
  String? selectedCategory;
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
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert), // 3점 버튼 아이콘
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                    1000.0, 80.0, 0.0, 0.0), // 메뉴가 화면의 오른쪽에 나오도록 위치 지정
                items: [
                  PopupMenuItem<String>(
                    value: 'settings',
                    child: Text('기본 식품 카테고리 관리'),
                  ),
                  PopupMenuItem<String>(
                    value: 'feedback',
                    child: Text('선호 식품 카테고리 관리'),
                  ),
                ],
                elevation: 8.0,
              ).then((value) {
                if (value == 'settings') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddItem(
                        pageTitle: '기본 식품 카테고리에 추가',
                        addButton: '카테고리에 추가',
                        fridgeFieldIndex: '기본냉장고',
                        basicFoodsCategories: ['육류', '수산물', '채소', '과일', '견과'],
                        itemsByCategory: {
                          '육류': ['소고기', '돼지고기', '닭고기'],
                          '수산물': ['연어', '참치', '고등어'],
                          '채소': ['양파', '당근', '감자'],
                          '과일': [
                            '사과',
                            '바나나',
                            '포도',
                            '메론',
                            '자몽',
                            '블루베리',
                            '라즈베리',
                            '딸기',
                            '체리',
                            '오렌지',
                            '골드키위',
                            '참외',
                            '수박',
                            '감',
                            '복숭아',
                            '앵두',
                            '자두',
                            '배',
                            '코코넛',
                            '리치',
                            '망고',
                            '망고스틴',
                            '아보카도',
                            '복분자',
                            '샤인머스캣',
                            '용과',
                            '라임',
                            '레몬',
                            '천도복숭아',
                            '파인애플',
                            '애플망고',
                            '잭프릇',
                            '람보탄',
                            '아사히베리',
                            ''
                          ],
                          '견과': ['아몬드', '호두', '캐슈넛'],
                        }, // 원하는 카테고리 리스트), // 예시로 설정 페이지로 이동
                      ),
                    ),
                  );
                } else if (value == 'feedback') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddItem(
                        pageTitle: '선호식품 카테고리에 추가',
                        addButton: '카테고리에 추가',
                        fridgeFieldIndex: '기본냉장고',
                        basicFoodsCategories: ['비건', '다이어트', '무오신채', '알레르기', '채식'],
                        itemsByCategory: {
                          '비건': ['육류', '어패류', '꿀'],
                          '다이어트': ['튀기기', '밀가루', '설탕'],
                          '오신채': ['부추', '마늘', '파', '달래', '양파'],
                          '알레르기': ['복숭아', '우유', '파인애플'],
                          '채식': ['육류', '어패류', '팜유'],
                        }, // 원하는 카테고리 리스트), // 의견 보내기 페이지로 이동
                      ),
                    ),
                  );
                }
              });
            },
          ),
        ],
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
                MaterialPageRoute(
                    builder: (context) =>
                        AccountInformation()), // 계정 정보 페이지로 이동
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
                MaterialPageRoute(
                    builder: (context) => AppUsageSettings()), // 계정 정보 페이지로 이동
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
                MaterialPageRoute(
                    builder: (context) =>
                        AppEnvironmentSettings()), // 계정 정보 페이지로 이동
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
                MaterialPageRoute(
                    builder: (context) =>
                        FeedbackSubmission()), // 계정 정보 페이지로 이동
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
                MaterialPageRoute(
                    builder: (context) => AdminLogin()), // 계정 정보 페이지로 이동
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
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: '장보기'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: '레시피'),
          BottomNavigationBarItem(
              icon: Icon(Icons.drive_file_rename_outline_rounded), label: '기록'),
        ],
        currentIndex: _selectedIndex, // 현재 선택된 탭
        onTap: _onItemTapped, // 탭 선택시 호출될 함수
      ),
    );
  }
}

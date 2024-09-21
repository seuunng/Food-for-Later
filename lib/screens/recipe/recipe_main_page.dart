import 'package:flutter/material.dart';
import 'package:food_for_later/screens/recipe/add_recipe.dart';
import 'package:food_for_later/screens/recipe/recipe_grid.dart';
import 'package:food_for_later/screens/recipe/recipe_grid_theme.dart';
import 'package:food_for_later/screens/recipe/view_research_list.dart';
import 'package:food_for_later/screens/recipe/view_scrap_recipe_list.dart';

class RecipeMainPage extends StatefulWidget {
  final List<String> category;
  RecipeMainPage({
    required this.category,
  });
  @override
  _RecipeMainPageState createState() => _RecipeMainPageState();
}

class _RecipeMainPageState extends State<RecipeMainPage>
    with SingleTickerProviderStateMixin {
  String searchKeyword = '';
  Map<String, List<String>> itemsByCategory = {
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
  };


  final List<Tab> myTabs = <Tab>[
    Tab(text: '재료별'),
    Tab(text: '테마별'),
    Tab(text: '조리방법별'),
  ];

  // 검색된 아이템 상태를 관리할 리스트
  List<String> filteredItems = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  void _searchItems(String keyword) {
    List<String> tempFilteredItems = [];
    setState(() {
      searchKeyword = keyword.trim().toLowerCase();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewResearchList(
              category: [searchKeyword],  // 필터링된 결과를 category로 넘김
            ),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('레시피'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: '검색어 입력',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _searchItems(value); // 검색어 입력 시 아이템 필터링
                    },
                    onSubmitted: (value) {
                      // 엔터 키를 눌렀을 때 ViewResearchList로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewResearchList(
                              category: [searchKeyword], // 필터링된 결과 전달
                            ),
                          ),
                        );

                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark, size: 60), // 스크랩 아이콘 크기 조정
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewScrapRecipeList(),
                      ),
                    );// 스크랩 아이콘 클릭 시 실행할 동작
                  },
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: myTabs,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RecipeGrid(
                    categories: [
                      '육류',
                      '수산물',
                      '채소',
                      '과일',
                      '견과'
                    ],
                    itemsByCategory:{
                      '육류': ['소고기', '돼지고기', '닭고기'],
                      '수산물': ['연어', '참치', '고등어'],
                      '채소': ['양파', '당근', '감자'],
                      '과일': [
                        '사과', '바나나', '포도', '메론', '자몽', '블루베리', '라즈베리', '딸기', '체리', '오렌지', '골드키위', '참외', '수박', '감',
                        '복숭아', '앵두', '자두', '배', '코코넛', '리치', '망고', '망고스틴', '아보카도', '복분자', '샤인머스캣', '용과', '라임', '레몬', '천도복숭아', '파인애플', '애플망고', '잭프릇', '람보탄', '아사히베리', ''
                      ],
                      '견과': ['아몬드', '호두', '캐슈넛'],
                    }
                ),
                RecipeGridTheme(
                    categories: [
                      '다이어트',
                      '편스토랑',
                      '집밥백선생',
                      '리틀포레스트',
                      '손님대접'
                    ],
                ),
                RecipeGrid(
                    categories: [
                    ],
                    itemsByCategory:{'': [
                      '끓이기',
                      '데치기',
                      '에어프라이어',
                      '오븐',
                      '비조리'
                    ]}),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed:(){
                  if (widget.category.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewResearchList(
                          category: widget.category,
                        ),
                      ),
                    );
                  } else {
                    // Handle the case where category is empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('카테고리를 입력해주세요.'),
                      ),
                    );
                  }
                },
                child: Text('냉장고 재료 레시피 추천'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15), // 위아래 패딩을 조정하여 버튼 높이 축소
                  // backgroundColor: isDeleteMode ? Colors.red : Colors.blueAccent, // 삭제 모드일 때 빨간색, 아닐 때 파란색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게
                  ),
                  elevation: 5,
                  textStyle: TextStyle(
                    fontSize: 18, // 글씨 크기 조정
                    fontWeight: FontWeight.w500, // 약간 굵은 글씨체
                    letterSpacing: 1.2, //
                  ),
                  // primary: isDeleteMode ? Colors.red : Colors.blue,
                ),
              ),
            ),
            SizedBox(width: 20),
            // 물건 추가 버튼
            FloatingActionButton(
              heroTag: 'recipe_add_button',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRecipe(),
                    fullscreenDialog: true, // 모달 다이얼로그처럼 보이게 설정
                  ),
                );
              },
              child: Icon(Icons.add),

            ),
          ],
        ),
      ),
    );
  }
}

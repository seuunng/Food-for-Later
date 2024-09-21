import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';
import 'package:intl/intl.dart';

class FridgeItemDetails extends StatefulWidget {
  final String categoryName; // 선택된 냉장고 카테고리명
  final String categoryFoodsName; // 선택된 냉장고 카테고리명
  final int expirationDays; // 유통기한
  final int consumptionDays; // 품질유지기한
  final String registrationDate; // 등록일

  FridgeItemDetails({
    required this.categoryName,
    required this.categoryFoodsName,
    required this.expirationDays,
    required this.consumptionDays,
    required this.registrationDate,
  });

  @override
  _FridgeItemDetailsState createState() => _FridgeItemDetailsState();
}

class _FridgeItemDetailsState extends State<FridgeItemDetails> {
  // 냉장고 카테고리 상수 리스트
  static const List<String> fridgeCategories = ['냉장', '냉동', '상온'];
  static const List<String> basicFoodsCategories = [
    '육류',
    '수산물',
    '채소',
    '과일',
    '견과'
  ];
  // 각 카테고리별 아이템 리스트 (예시 데이터)
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

  // 드롭다운 선택된 값 저장 변수
  String? selectedCategory;
  String? selectedFoodsCategory;
  String? selectedFoods;
  int expirationDays = 1; // 유통기한 기본값
  int consumptionDays = 1; // 품질유지기한 기본값
  // Date registrationDate;

  // 입력 필드 컨트롤러
  TextEditingController foodNameController = TextEditingController();
  TextEditingController dateController = TextEditingController(); // 등록일 컨트롤러

  // 현재 날짜
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    dateController.text =
        DateFormat('yyyy-MM-dd').format(currentDate); // 초기 등록일을 현재 날짜로 설정
    // 선택된 카테고리가 기본 카테고리 목록에 있는지 확인
    if (basicFoodsCategories.contains(widget.categoryName)) {
      selectedFoodsCategory = widget.categoryName; // 유효한 경우 카테고리 설정
    } else {
      selectedFoodsCategory = null;
    }
    // 선택된 값이 itemsByCategory에서 정확하게 있는지 확인 후 없으면 null 설정
    selectedFoods = itemsByCategory[widget.categoryName]
                ?.contains(widget.categoryFoodsName) ==
            true
        ? widget.categoryFoodsName
        : null;
    expirationDays = widget.expirationDays;
    consumptionDays = widget.consumptionDays;
    dateController.text = widget.registrationDate;
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != currentDate) {
      setState(() {
        currentDate = pickedDate;
        dateController.text = DateFormat('yyyy-MM-dd').format(currentDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 날짜를 "YYYY-MM-DD" 형식으로 포맷
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('상세보기'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: Center(child: Icon(Icons.image, size: 50)),
                  ), // 이미지 추가 예시
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('카테고리명   ', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: selectedFoodsCategory,
                            hint: Text('카테고리 선택'),
                            items: basicFoodsCategories.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedFoodsCategory = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('식품명', style: TextStyle(fontSize: 18)),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            // 원하는 크기로 설정
                            child: TextField(
                              controller: foodNameController
                                ..text = selectedFoods ?? '',
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '식품명을 입력하세요',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('냉장고 카테고리', style: TextStyle(fontSize: 18)),
                  Spacer(),
                  DropdownButton<String>(
                    value: selectedCategory,
                    hint: Text('카테고리 선택'),
                    items: fridgeCategories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                  SizedBox(width: 20),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('유통기한', style: TextStyle(fontSize: 18)),
                  Spacer(),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (expirationDays > 1) expirationDays--;
                          });
                        },
                      ),
                      Text('$expirationDays 일', style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            expirationDays++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              // 소비기한 선택 드롭다운
              Row(
                children: [
                  Text('품질유지기한', style: TextStyle(fontSize: 18)),
                  Spacer(),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (consumptionDays > 1) consumptionDays--;
                          });
                        },
                      ),
                      Text('$consumptionDays 일',
                          style: TextStyle(fontSize: 18)),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            consumptionDays++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('등록일', style: TextStyle(fontSize: 18)),
                  Spacer(),
                  SizedBox(
                    width: 150, // 필드 크기
                    child: TextField(
                      controller: dateController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: '날짜 선택',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context), // 날짜 선택 다이얼로그 호출
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
      // 하단에 추가 버튼 추가
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('추가하기 버튼 클릭됨')),
              );
            },
            child: Text(
              '저장하기',
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게
              ),
              elevation: 5,
              textStyle: TextStyle(
                fontSize: 18, // 글씨 크기 조정
                fontWeight: FontWeight.w500, // 약간 굵은 글씨체
                letterSpacing: 1.2, //
              ),
            ),
          ),
        ),
      ),
    );
  }
}

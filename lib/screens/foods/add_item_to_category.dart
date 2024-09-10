import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';
import 'package:intl/intl.dart';

class AddItemToCategory extends StatefulWidget {
  final String categoryName;  // 선택된 카테고리명을 받을 변수

  AddItemToCategory({required this.categoryName});  // 생성자에서 카테고리명 받기

  @override
  _AddItemToCategoryState createState() => _AddItemToCategoryState();
}

class _AddItemToCategoryState extends State<AddItemToCategory> {
  // 냉장고 카테고리 상수 리스트
  static const List<String> fridgeCategories = ['냉장', '냉동', '상온'];
  static const List<String> basicFoodsCategories = [
    '육류',
    '수산물',
    '채소',
    '과일',
    '견과'
  ];

  // 드롭다운 선택된 값 저장 변수
  String? selectedCategory;
  String? selectedFoodsCategory;
  int expirationDays = 1; // 유통기한 기본값
  int consumptionDays = 1; // 품질유지기한 기본값

  // 입력 필드 컨트롤러
  TextEditingController foodNameController = TextEditingController();
  TextEditingController dateController = TextEditingController(); // 등록일 컨트롤러

  // 현재 날짜
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('yyyy-MM-dd').format(currentDate); // 초기 등록일을 현재 날짜로 설정
    // 선택된 카테고리가 기본 카테고리 목록에 있는지 확인
    if (basicFoodsCategories.contains(widget.categoryName)) {
      selectedFoodsCategory = widget.categoryName; // 유효한 경우 카테고리 설정
    } else {
      selectedFoodsCategory = null; // 유효하지 않으면 null로 설정
    }
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
        title: Text('기본 식품 카테고리에 추가하기'),
      ),
      body: Padding(
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
                    SizedBox(
                      width: 200, // 원하는 크기로 설정
                      child: TextField(
                        controller: foodNameController,
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
                    Text('$consumptionDays 일', style: TextStyle(fontSize: 18)),
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
                SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
      // 하단에 추가 버튼 추가
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50, // 버튼 높이 설정
          child: ElevatedButton(
            onPressed: () {
              // 버튼 눌렀을 때 실행될 함수 추가
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('추가하기 버튼 클릭됨')),
              );
            },
            child: Text(
              '추가하기',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}

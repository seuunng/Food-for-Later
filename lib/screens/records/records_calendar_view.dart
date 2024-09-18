import 'package:flutter/material.dart';
import 'package:food_for_later/screens/records/read_record.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class RecordsCalendarView extends StatefulWidget {
  @override
  _RecordsCalendarViewState createState() => _RecordsCalendarViewState();
}

class _RecordsCalendarViewState extends State<RecordsCalendarView> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  List<Map<String, dynamic>> recordsList = [
    {
      'zone': '식단',
      'color': Colors.blueAccent.shade100,
      'date': '2024-09-17',
      'records': [
        {
          'unit': '아침',
          'contents': '맛있었습니다!',
          'images': [
            'assets/step1.jpeg',
            'assets/step2.jpeg',
            'assets/step3.jpeg'
          ],
        },
        {
          'unit': '점심',
          'contents': '점심도 맛있었습니다!',
          'images': [
            'assets/step1.jpeg',
            'assets/step2.jpeg',
            'assets/step3.jpeg'
          ],
        }
      ]
    },
    {
      'zone': '운동',
      'color': Colors.greenAccent.shade100,
      'date': '2024-09-19',
      'records': [
        {
          'unit': '저녁',
          'contents': '운동을 했습니다!',
          'images': [
            'assets/step1.jpeg',
            'assets/step2.jpeg',
            'assets/step3.jpeg'
          ],
        }
      ]
    },
  ];

  List<Map<String, dynamic>>? getRecordsForDate(DateTime date) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return recordsList
        .where((record) => record['date'] == formattedDate)
        .toList();
  }

  // 일주일 범위를 계산하는 함수
  List<DateTime> _getWeekDates(DateTime date) {
    int currentWeekday = date.weekday; // 현재 요일 (1: 월요일 ~ 7: 일요일)
    DateTime sunday =
        date.subtract(Duration(days: currentWeekday % 7)); // 일요일 계산
    List<DateTime> weekDates = List.generate(
        7, (index) => sunday.add(Duration(days: index))); // 일주일 생성
    return weekDates;
  }

// 선택된 날짜 기준으로 일주일을 렌더링하는 함수
  Widget _buildWeekContainer() {
    List<DateTime> weekDates = _getWeekDates(_selectedDate);

    return Container(
      child: ListView.builder(
        shrinkWrap: true, // ListView가 자식에 맞게 크기를 조정
        physics: NeverScrollableScrollPhysics(), // 부모 스크롤에 맞게 비활성화
        itemCount: weekDates.length,
        itemBuilder: (context, index) {
          DateTime date = weekDates[index];
          List<Map<String, dynamic>>? recordsForDate = getRecordsForDate(date);
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5.0),
            constraints: BoxConstraints(
              minHeight: 100, // 각 컬럼의 최소 높이 설정
            ),
            decoration: BoxDecoration(
              color: Colors.white, // 배경을 흰색으로 설정
              borderRadius: BorderRadius.circular(10), // 둥근 모서리
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // 그림자 색상
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // 그림자의 위치
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('E').format(date)}  ${date.day}', // 요일과 날짜 출력
                      textAlign: TextAlign.left,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (recordsForDate != null) // 해당 날짜에 기록이 있을 때만 렌더링
                      Column(
                        children: recordsForDate.map((record) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ReadRecord(
                                            recordData: [record],
                                          )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: record['records']
                                        .map<Widget>((recordItem) {
                                      return Row(
                                        children: [
                                          // 이미지와 텍스트를 묶어서 하나의 Column에 배치하고 중앙 정렬
                                          Center(
                                            child: recordItem['images']
                                                    .isNotEmpty
                                                ? Column(
                                                    children: [
                                                      Image.asset(
                                                        recordItem['images'][0],
                                                        height: 50, // 이미지 높이
                                                        width: 50, // 이미지 너비
                                                        fit: BoxFit.cover,
                                                      ),
                                                      SizedBox(
                                                        height: 3,
                                                      ),
                                                    ],
                                                  )
                                                : Icon(Icons.image),
                                          ),
                                          SizedBox(
                                              width: 15), // 이미지와 텍스트 사이에 간격 추가
                                          Center(
                                            child: Text(
                                              recordItem['contents'] ??
                                                  '내용이 없습니다',
                                              style: TextStyle(fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: Column(
            children: [
              // 월과 년도 표시
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _focusedDate = DateTime(
                              _focusedDate.year, _focusedDate.month - 1, 1);
                        });
                      },
                    ),
                    Text(
                      DateFormat.yMMM().format(_focusedDate),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _focusedDate = DateTime(
                              _focusedDate.year, _focusedDate.month + 1, 1);
                        });
                      },
                    ),
                  ],
                ),
              ),
              // 달력 헤더 (요일 표시)
              GridView.count(
                crossAxisCount: 7,
                childAspectRatio: 2, // 7열로 설정 (일~토)
                shrinkWrap: true, // GridView 높이 조정
                children: ["일", "월", "화", "수", "목", "금", "토"]
                    .map((day) => Center(
                          child: Text(
                            day,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
              ),
              // 날짜 그리드
              GridView.builder(
                itemCount: _daysInMonth(_focusedDate),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, // 7열로 설정
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 0.8),
                shrinkWrap: true, // GridView를 스크롤이 아닌 적절한 크기로 축소
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final date =
                      DateTime(_focusedDate.year, _focusedDate.month, day);
                  bool isSelected = date == _selectedDate;
                  bool isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;

                  // 해당 날짜에 기록이 있는지 확인
                  List<Map<String, dynamic>>? recordsForDate =
                      getRecordsForDate(date);
                  Color? backgroundColor;
                  String? contents;

                  if (recordsForDate != null && recordsForDate.isNotEmpty) {
                    // 기록이 있을 경우 첫 번째 기록의 색상과 타이틀을 사용
                    backgroundColor = recordsForDate.first['color'];
                    contents = recordsForDate.first['contents'] ?? '내용이 없습니다';
                  }
                  return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.transparent //선택한 날
                              : isToday
                                  ? Colors.white //오늘
                                  : Colors.transparent, //기본
                          borderRadius: BorderRadius.circular(8.0),
                          border: isSelected
                              ? Border.all(color: Colors.black, width: 2.0)
                              : null,
                        ),
                        child: Align(
                          alignment: Alignment.topLeft, // 텍스트를 상단 왼쪽으로 정렬
                          child: Padding(
                            padding: const EdgeInsets.all(1.0), // 약간의 패딩 추가
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$day',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : isToday
                                            ? Colors.grey
                                            : Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                // 해당 날짜의 기록들이 있는지 확인하고, 각각을 렌더링
                                if (recordsForDate != null)
                                  ...recordsForDate.map((record) {
                                    return GestureDetector(
                                      // GestureDetector로 onTap 기능 추가
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReadRecord(
                                              recordData: [record],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.only(top: 2), // 항목 간의 간격
                                        padding: EdgeInsets.all(1),
                                        width:
                                            MediaQuery.of(context).size.width /
                                                7,
                                        decoration: BoxDecoration(
                                          color:
                                              record['color'], // 각 기록의 배경색 적용
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Column(
                                          children: record['records']
                                              .map<Widget>((recordItem) {
                                            return Text(
                                              recordItem['contents'] ??
                                                  '내용이 없습니다', // 리스트 항목별로 contents에 접근
                                              style: TextStyle(fontSize: 8),
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ));
                },
              ),
              _buildWeekContainer(),
            ],
          ),
        ),
      ),
    );
  }

  // 이번 달의 일수를 반환하는 함수
  int _daysInMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(Duration(days: 1)).day;
  }
}

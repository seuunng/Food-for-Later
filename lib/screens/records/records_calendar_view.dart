import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class RecordsCalendarView extends StatefulWidget {
  @override
  _RecordsCalendarViewState createState() => _RecordsCalendarViewState();
}

class _RecordsCalendarViewState extends State<RecordsCalendarView> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  Map<DateTime, List<Map<String, dynamic>>> recordsData = {
    DateTime(2024, 9, 18): [
      {
        'zone': '식단',
        'title': '아침 식사',
        'color': Colors.blueAccent.shade100,
      },
    ],
    DateTime(2024, 9, 19): [
      {
        'zone': '운동',
        'title': '아침 운동',
        'color': Colors.greenAccent.shade100,
      },
      {
        'zone': '식단',
        'title': '점심 식사',
        'color': Colors.blueAccent.shade100,
      },
    ],
    DateTime(2024, 9, 20): [
      {
        'zone': '식단',
        'title': '저녁 식사',
        'color': Colors.blueAccent.shade100,
      },
    ],
  };
  // 날짜 선택 시 호출되는 함수
  void _onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _focusedDate = focusedDate;
    });
  }

  // 날짜의 시간 정보를 제거하고 비교하는 함수
  List<Map<String, dynamic>>? getRecordsForDate(DateTime date) {
    return recordsData[DateTime(date.year, date.month, date.day)];
  }

  // 기록 보여주기 그리드
  Widget _buildRecordsForSelectedDate() {
    List<Map<String, dynamic>>? recordsForDate =
        getRecordsForDate(_selectedDate);

    if (recordsForDate == null || recordsForDate.isEmpty) {
      return Center(
        child: Text('해당 날짜에 기록된 섹션이 없습니다.'),
      );
    }

    return ListView.builder(
      itemCount: recordsForDate.length,
      itemBuilder: (context, index) {
        var record = recordsForDate[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 40,
                color: record['color'], // zone에 따른 색상
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record['zone'], // zone (예: '식단', '운동')
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    record['title'], // title (예: '아침 식사')
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          Expanded(
              child: GridView.builder(
            itemCount: _daysInMonth(_focusedDate),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7열로 설정
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 0.8),
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = DateTime(_focusedDate.year, _focusedDate.month, day);
              bool isSelected = date == _selectedDate;
              bool isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              // 해당 날짜에 기록이 있는지 확인
              List<Map<String, dynamic>>? recordsForDate =
                  getRecordsForDate(date);
              Color? backgroundColor;
              String? title;

              if (recordsForDate != null && recordsForDate.isNotEmpty) {
                // 기록이 있을 경우 첫 번째 기록의 색상과 타이틀을 사용
                backgroundColor = recordsForDate.first['color'];
                title = recordsForDate.first['title'];
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
                        padding: const EdgeInsets.all(2.0), // 약간의 패딩 추가
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
                                return Container(
                                  margin: EdgeInsets.only(top: 2), // 항목 간의 간격
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: record['color'], // 각 기록의 배경색 적용
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    record['title'],
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.black,
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
          ))
        ],
      ),
    );
  }

  // 이번 달의 일수를 반환하는 함수
  int _daysInMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(Duration(days: 1)).day;
  }
}

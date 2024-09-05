import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class RecordsCalendarView extends StatefulWidget {
  @override
  _RecordsCalendarViewState createState() => _RecordsCalendarViewState();
}

class _RecordsCalendarViewState extends State<RecordsCalendarView> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  // 날짜 선택 시 호출되는 함수
  void _onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    setState(() {
      _selectedDate = selectedDate;
      _focusedDate = focusedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('달력형'),
      ),
      body: Column(
        children: [
          // TableCalendar 위젯
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDate,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: _onDaySelected,
            calendarFormat: CalendarFormat.month,
            headerStyle: HeaderStyle(
              formatButtonVisible: false, // 주/월 변환 버튼 비활성화
              titleCentered: true, // 타이틀 중앙 정렬
            ),
          ),
          // 선택한 날짜를 표시하는 부분
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '선택한 날짜: ${_selectedDate.toLocal()}'.split(' ')[0],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 여기에 레시피 목록 UI 추가 가능
        ],
      ),
    );
  }
}

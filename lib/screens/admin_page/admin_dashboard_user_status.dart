import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/user_status_chart/user_age.dart';
import 'package:food_for_later/screens/admin_page/user_status_chart/user_statistics.dart';
import 'package:food_for_later/screens/admin_page/user_status_chart/user_time.dart';

class AdminDashboardUserStatus extends StatefulWidget {
  @override
  _AdminDashboardUserStatusState createState() =>
      _AdminDashboardUserStatusState();
}

class _AdminDashboardUserStatusState extends State<AdminDashboardUserStatus> {
  @override
  Widget build(BuildContext context) {
    List<double> points_time = [50, 90, 103, 500, 150, 120, 200, 80];
    List<String> labels_time = ["0", "3", "6", "9", "12", "15", "18", "21"];
    List<double> points_age = [50, 90, 70, 100, 60, 90, 10];
    List<String> labels_age = ["10", "20", "30", "40", "50", "60", "70"];

    return Scaffold(
      appBar: AppBar(
        title: Text('사용자 현황'),
      ),
      body: ListView(
        children: [
          // 드롭다운 카테고리 선택
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                '사용자 수 현황',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            height: 200,
            child: UserStatistics(),
          ),
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                '사용자 연령대 현황',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            height: 200,
            child: UserAge(),
          ),
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                '사용자 사용시간 현황',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            height: 200,
            child: UserTime(),
          ),
          Row(
            children: [
              SizedBox(width: 16),
              Text(
                '회원목록',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(), // 텍스트와 드롭다운 사이 간격
            ],
          ),
          DataTable(columns: [
            DataColumn(label: Text('이름')),
            DataColumn(label: Text('출생년도'), numeric: true),
            DataColumn(label: Text('성별')),
            DataColumn(label: Text('최종학력')),
            DataColumn(label: Text('고향')),
          ], rows: [
            DataRow(cells: [
              DataCell(Text('철수')),
              DataCell(Text('1977')),
              DataCell(Text('남')),
              DataCell(Text('학사')),
              DataCell(Text('부산')),
            ]),
          ]),
        ],
      ),
    );
  }
}

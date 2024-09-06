import 'package:flutter/material.dart';

class AdminAppSettingsManagement extends StatefulWidget {
  @override
  _AdminAppSettingsManagementState createState() =>
      _AdminAppSettingsManagementState();
}

class _AdminAppSettingsManagementState
    extends State<AdminAppSettingsManagement> {
  final List<Tab> myTabs = <Tab>[
    Tab(text: '재료별 카테고리'),
    Tab(text: '테마별 카테고리'),
    Tab(text: '조리방법별 카테고리'),
    Tab(text: '기본식품 카테고리'),
    Tab(text: '선호식품 카테고리'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('어플 설정'),
          bottom: TabBar(
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          children: myTabs.map((Tab tab) {
            final String label = tab.text!.toLowerCase();
            return DataTable(columns: [
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
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

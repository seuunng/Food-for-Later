import 'package:flutter/material.dart';

class AdminFeedbackManagement extends StatefulWidget {
  @override
  _AdminFeedbackManagementState createState() => _AdminFeedbackManagementState();
}

class _AdminFeedbackManagementState extends State<AdminFeedbackManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('의견 및 신고 처리하기'),
      ),
      body: Column(
        children: [
          DataTable(columns: [
            DataColumn(label: Text('연번')),
            DataColumn(label: Text('날짜')),
            DataColumn(label: Text('제목')),
            DataColumn(label: Text('작성자')),
            DataColumn(label: Text('처리결과')),
          ], rows: [
            DataRow(cells: [
              DataCell(Text('1')),
              DataCell(Text('2024.12.32')),
              DataCell(Text('오타 발견')),
              DataCell(Text('승희네')),
              DataCell(Text('수정완료')),
            ]),
          ]),
        ],
      ),
    );
  }
}
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
          Center(
            child: Text('의견 및 신고 처리하기'),
          ),
        ],
      ),
    );
  }
}
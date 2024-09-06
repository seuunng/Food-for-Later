import 'package:flutter/material.dart';

class AdminPasswordChange extends StatefulWidget {
  @override
  _AdminPasswordChangeState createState() => _AdminPasswordChangeState();
}

class _AdminPasswordChangeState extends State<AdminPasswordChange> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자 비밀번호 변경'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('관리자 비밀번호 변경'),
          ),
        ],
      ),
    );
  }
}
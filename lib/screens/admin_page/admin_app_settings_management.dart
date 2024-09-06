import 'package:flutter/material.dart';

class AdminAppSettingsManagement extends StatefulWidget {
  @override
  _AdminAppSettingsManagementState createState() => _AdminAppSettingsManagementState();
}

class _AdminAppSettingsManagementState extends State<AdminAppSettingsManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('어플 설정'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('어플 설정'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class AdminDashboardTrends extends StatefulWidget {
  @override
  _AdminDashboardTrendsState createState() => _AdminDashboardTrendsState();
}

class _AdminDashboardTrendsState extends State<AdminDashboardTrends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('트렌드'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('트렌드'),
          ),
        ],
      ),
    );
  }
}
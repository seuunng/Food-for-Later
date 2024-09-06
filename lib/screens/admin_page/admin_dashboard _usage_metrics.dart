import 'package:flutter/material.dart';

class AdminDashboardUsageMetrics extends StatefulWidget {
  @override
  _AdminDashboardUsageMetricsState createState() => _AdminDashboardUsageMetricsState();
}

class _AdminDashboardUsageMetricsState extends State<AdminDashboardUsageMetrics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('어플 실적 현황'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('어플 실적 현황'),
          ),
        ],
      ),
    );
  }
}
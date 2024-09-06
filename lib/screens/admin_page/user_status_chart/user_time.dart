import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UserTime extends StatefulWidget {
  const UserTime({super.key});

  @override
  State<StatefulWidget> createState() => UserTimeState();
}

class UserTimeState extends State<UserTime> {
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  // bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Container( // 차트의 화면 비율을 설정
        constraints: BoxConstraints(
          maxWidth: double.infinity, // 부모 컨테이너의 가로를 채움
          maxHeight: 300, // 최대 세로 크기
        ),
        decoration: BoxDecoration(
          color: Colors.white, // 배경색 설정
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // 그림자 위치
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0),
          child: BarChart(
            mainBarData(), // 차트 데이터를 mainBarData로 설정
            swapAnimationDuration: animDuration,
          ),
        ),
    );
  }

  // 차트 그룹 데이터 생성
  BarChartGroupData makeGroupData(
      int x,
      double y, {
        bool isTouched = false,
        Color? barColor,
        double width = 22,
        List<int> showTooltips = const [],
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? Colors.green : barColor ?? Colors.blueAccent,
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.green)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: Colors.grey.withOpacity(0.2), // 배경 설정
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  // 실제 데이터를 보여줄 함수
  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              'Value\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '${rod.toY - 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              );
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = const Text('0시', style: style);
                  break;
                case 1:
                  text = const Text('3시', style: style);
                  break;
                case 2:
                  text = const Text('6시', style: style);
                  break;
                case 3:
                  text = const Text('9시', style: style);
                  break;
                case 4:
                  text = const Text('12시', style: style);
                  break;
                case 5:
                  text = const Text('15시', style: style);
                  break;
                case 6:
                  text = const Text('18시', style: style);
                  break;
                case 7:
                  text = const Text('21시', style: style);
                  break;
                default:
                  text = const Text('', style: style);
                  break;
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: text,
              );
            },
            reservedSize: 30,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  // 차트 그룹 데이터를 생성하는 함수
  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
    return makeGroupData(i, 5 + i.toDouble());
  });
}
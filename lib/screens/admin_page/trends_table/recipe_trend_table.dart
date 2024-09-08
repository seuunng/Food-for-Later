import 'package:flutter/material.dart';

enum SortState { none, ascending, descending }

class RecipeTrendTable extends StatefulWidget {
  @override
  _RecipeTrendTableState createState() => _RecipeTrendTableState();
}

class _RecipeTrendTableState extends State<RecipeTrendTable> {
  // 각 열에 대한 정렬 상태를 관리하는 리스트
  List<Map<String, dynamic>> columns = [
    {'name': '순위', 'state': SortState.none},
    {'name': '제목', 'state': SortState.none},
    {'name': '닉네임', 'state': SortState.none},
    {'name': '작성일', 'state': SortState.none},
    {'name': '조회수', 'state': SortState.none},
    {'name': '스크랩', 'state': SortState.none},
    {'name': '따라하기', 'state': SortState.none},
    {'name': '공유', 'state': SortState.none},
  ];

  // 사용자 데이터
  List<Map<String, dynamic>> userData = [
    {
      '순위': 1,
      '제목': '탄탄멘',
      '닉네임': '승희네',
      '작성일': '2024/05/17',
      '조회수': 300,
      '스크랩': 20,
      '따라하기': 100,
      '공유': 10,
    },
    {
      '순위': 2,
      '제목': '마라샹궈',
      '닉네임': '승희네',
      '작성일': '2024/05/18',
      '조회수': 290,
      '스크랩': 21,
      '따라하기': 110,
      '공유': 1,
    },
    {
      '순위': 3,
      '제목': '또띠아피자',
      '닉네임': '승희네',
      '작성일': '2024/05/10',
      '조회수': 30,
      '스크랩': 10,
      '따라하기': 20,
      '공유': 3,
    },
  ];

  void _sortBy(String columnName, SortState currentState) {
    setState(() {
      // 열의 정렬 상태를 업데이트
      for (var column in columns) {
        if (column['name'] == columnName) {
          column['state'] = currentState == SortState.none
              ? SortState.ascending
              : (currentState == SortState.ascending
                  ? SortState.descending
                  : SortState.none);
        } else {
          column['state'] = SortState.none;
        }
      }

      // 정렬 수행
      if (currentState == SortState.none) {
        // 정렬 없으면 원래 데이터 순서 유지
        userData.sort((a, b) => a['순위'].compareTo(b['순위']));
      } else {
        userData.sort((a, b) {
          int result;
          result = a[columnName].compareTo(b[columnName]);
          return currentState == SortState.ascending ? result : -result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns.map((column) {
            return DataColumn(
              label: GestureDetector(
                onTap: () => _sortBy(column['name'], column['state']),
                child: Row(
                  children: [
                    Text(column['name']),
                    Icon(
                      column['state'] == SortState.ascending
                          ? Icons.arrow_upward
                          : column['state'] == SortState.descending
                              ? Icons.arrow_downward
                              : Icons.sort,
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          rows: userData.map((row) {
            return DataRow(cells: [
              DataCell(Text(row['순위'].toString())), // '순위' 필드 사용
              DataCell(Text(row['제목'].toString())), // '제목' 필드 사용
              DataCell(Text(row['닉네임'].toString())), // '닉네임' 필드 사용
              DataCell(Text(row['작성일'].toString())), // '작성일' 필드 사용
              DataCell(Text(row['조회수'].toString())), // '조회수' 필드 사용
              DataCell(Text(row['스크랩'].toString())), // '스크랩' 필드 사용
              DataCell(Text(row['따라하기'].toString())), // '따라하기' 필드 사용
              DataCell(Text(row['공유'].toString())), // '공유' 필드 사용
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

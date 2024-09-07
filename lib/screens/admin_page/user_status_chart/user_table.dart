import 'package:flutter/material.dart';

enum SortState { none, ascending, descending }

class UserTable extends StatefulWidget {
  @override
  _UserTableState createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  // 각 열에 대한 정렬 상태를 관리하는 리스트
  List<Map<String, dynamic>> columns = [
    {'name': '연번', 'state': SortState.none},
    {'name': '닉네임', 'state': SortState.none},
    {'name': '가입일', 'state': SortState.none},
    {'name': '성별', 'state': SortState.none},
    {'name': '생년월일', 'state': SortState.none},
    {'name': '오픈횟수', 'state': SortState.none},
    {'name': '사용시간', 'state': SortState.none},
    {'name': '레시피', 'state': SortState.none},
    {'name': '기록', 'state': SortState.none},
    {'name': '스크랩', 'state': SortState.none},
  ];

  // 사용자 데이터
  List<Map<String, dynamic>> userData = [
    {
      '연번': 1,
      '닉네임': '승희네',
      '가입일': '2024/04/30',
      '성별': '여성',
      '생년월일': '1989/05/17',
      '오픈횟수': 20,
      '사용시간': 100,
      '레시피': 10,
      '기록': 30,
      '스크랩': 45,
    },
    {
      '연번': 2,
      '닉네임': '지환',
      '가입일': '2024/05/01',
      '성별': '남성',
      '생년월일': '1989/05/17',
      '오픈횟수': 15,
      '사용시간': 80,
      '레시피': 8,
      '기록': 25,
      '스크랩': 40,
    },
    {
      '연번': 3,
      '닉네임': '영희',
      '가입일': '2024/03/15',
      '성별': '여성',
      '생년월일': '1989/05/17',
      '오픈횟수': 30,
      '사용시간': 150,
      '레시피': 12,
      '기록': 40,
      '스크랩': 55,
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
        userData.sort((a, b) => a['연번'].compareTo(b['연번']));
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
    return SingleChildScrollView(
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
                  return DataRow(
                      cells: columns.map((column) {
                    return DataCell(Text(row[column['name']].toString()));
                  }).toList());
                }).toList(),
              ),
            );
  }
}

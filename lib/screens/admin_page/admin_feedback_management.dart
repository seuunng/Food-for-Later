import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/feedback_detail_page.dart';

enum SortState { none, ascending, descending }

class AdminFeedbackManagement extends StatefulWidget {
  @override
  _AdminFeedbackManagementState createState() =>
      _AdminFeedbackManagementState();
}

class _AdminFeedbackManagementState extends State<AdminFeedbackManagement> {
  String searchQuery = '';

  SortState _numberSortState = SortState.none;
  SortState _titleSortState = SortState.none;
  SortState _authorSortState = SortState.none;
  SortState _resultSortState = SortState.none;
  SortState _dateSortState = SortState.none;

  List<Map<String, String>> feedbackData = [
    {
      '연번': '1',
      '날짜': '2024/12/32',
      '제목': '오타 발견',
      '내용': '오타 수정 바랍니다.',
      '작성자': '승희네',
      '이메일': 'mnbxox@naever.com',
      '처리결과': '수정완료'
    },
    {
      '연번': '2',
      '날짜': '2024/12/31',
      '제목': '버그 신고',
      '내용': '버그 수정 바랍니다',
      '작성자': '철수',
      '이메일': 'mnb2856@naever.com',
      '처리결과': '확인 중'
    }
  ];
  // 원본 데이터 복사본 유지 (정렬 없음을 처리하기 위해)
  late List<Map<String, String>> originalData;

  @override
  void initState() {
    super.initState();
    originalData = List.from(feedbackData); // 초기 데이터 복사
  }

  void _sortByTitle() {
    setState(() {
      if (_titleSortState == SortState.none) {
        // 가나다순 정렬
        feedbackData.sort((a, b) => a['제목']!.compareTo(b['제목']!));
        _titleSortState = SortState.ascending;
      } else if (_titleSortState == SortState.ascending) {
        // 역가나다순 정렬
        feedbackData.sort((a, b) => b['제목']!.compareTo(a['제목']!));
        _titleSortState = SortState.descending;
      } else {
        // 정렬 없음을 선택하면 원래 데이터로 복원
        feedbackData = List.from(originalData);
        _titleSortState = SortState.none;
      }
    });
  }
  void _sortByNumber() {
    setState(() {
      if (_numberSortState == SortState.none) {
        // 가나다순 정렬
        feedbackData.sort((a, b) => a['연번']!.compareTo(b['연번']!));
        _numberSortState = SortState.ascending;
      } else if (_numberSortState == SortState.ascending) {
        // 역가나다순 정렬
        feedbackData.sort((a, b) => b['연번']!.compareTo(a['연번']!));
        _numberSortState = SortState.descending;
      } else {
        // 정렬 없음을 선택하면 원래 데이터로 복원
        feedbackData = List.from(originalData);
        _numberSortState = SortState.none;
      }
    });
  }
  void _sortByAuthor() {
    setState(() {
      if (_authorSortState == SortState.none) {
        // 가나다순 정렬
        feedbackData.sort((a, b) => a['작성자']!.compareTo(b['작성자']!));
        _authorSortState = SortState.ascending;
      } else if (_authorSortState == SortState.ascending) {
        // 역가나다순 정렬
        feedbackData.sort((a, b) => b['작성자']!.compareTo(a['작성자']!));
        _authorSortState = SortState.descending;
      } else {
        // 정렬 없음을 선택하면 원래 데이터로 복원
        feedbackData = List.from(originalData);
        _authorSortState = SortState.none;
      }
    });
  }
  void _sortByResult() {
    setState(() {
      if (_resultSortState == SortState.none) {
        // 가나다순 정렬
        feedbackData.sort((a, b) => a['처리결과']!.compareTo(b['처리결과']!));
        _resultSortState = SortState.ascending;
      } else if (_resultSortState == SortState.ascending) {
        // 역가나다순 정렬
        feedbackData.sort((a, b) => b['처리결과']!.compareTo(a['처리결과']!));
        _resultSortState = SortState.descending;
      } else {
        // 정렬 없음을 선택하면 원래 데이터로 복원
        feedbackData = List.from(originalData);
        _resultSortState = SortState.none;
      }
    });
  }
  void _sortByDate() {
    setState(() {
      if (_dateSortState == SortState.none) {
        // 가나다순 정렬
        feedbackData.sort((a, b) => a['날짜']!.compareTo(b['날짜']!));
        _dateSortState = SortState.ascending;
      } else if (_dateSortState == SortState.ascending) {
        // 역가나다순 정렬
        feedbackData.sort((a, b) => b['날짜']!.compareTo(a['날짜']!));
        _dateSortState = SortState.descending;
      } else {
        // 정렬 없음을 선택하면 원래 데이터로 복원
        feedbackData = List.from(originalData);
        _dateSortState = SortState.none;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredData = feedbackData
        .where((row) =>
            row['제목']!.toLowerCase().contains(searchQuery.toLowerCase()) ||
            row['작성자']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('의견 및 신고 처리하기'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) {
              setState(() {
                searchQuery = query;
              });
            },
          ),
        ),
        Expanded(
            child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // 가로 스크롤 가능하게 설정
          child: DataTable(
              columns: [
                DataColumn(label: GestureDetector(
                  onTap: _sortByNumber, // 제목을 누르면 정렬 상태 변경
                  child: Row(
                    children: [
                      Text('연번'),
                      Icon(
                        _numberSortState == SortState.ascending
                            ? Icons.arrow_upward
                            : _numberSortState == SortState.descending
                            ? Icons.arrow_downward
                            : Icons.sort,
                        size: 16,
                      ),
                    ],
                  ),
                ),),
                DataColumn(label: GestureDetector(
                  onTap: _sortByDate, // 제목을 누르면 정렬 상태 변경
                  child: Row(
                    children: [
                      Text('날짜'),
                      Icon(
                        _dateSortState == SortState.ascending
                            ? Icons.arrow_upward
                            : _dateSortState == SortState.descending
                            ? Icons.arrow_downward
                            : Icons.sort,
                        size: 16,
                      ),
                    ],
                  ),
                ),),
                DataColumn(label: GestureDetector(
                  onTap: _sortByTitle, // 제목을 누르면 정렬 상태 변경
                  child: Row(
                    children: [
                      Text('제목'),
                      Icon(
                        _titleSortState == SortState.ascending
                            ? Icons.arrow_upward
                            : _titleSortState == SortState.descending
                            ? Icons.arrow_downward
                            : Icons.sort,
                        size: 16,
                      ),
                    ],
                  ),
                ),),
                DataColumn(label: GestureDetector(
                  onTap: _sortByAuthor, // 제목을 누르면 정렬 상태 변경
                  child: Row(
                    children: [
                      Text('작성자'),
                      Icon(
                        _authorSortState == SortState.ascending
                            ? Icons.arrow_upward
                            : _authorSortState == SortState.descending
                            ? Icons.arrow_downward
                            : Icons.sort,
                        size: 16,
                      ),
                    ],
                  ),
                ),),
                DataColumn(label: GestureDetector(
                  onTap: _sortByResult, // 제목을 누르면 정렬 상태 변경
                  child: Row(
                    children: [
                      Text('처리결과'),
                      Icon(
                        _resultSortState == SortState.ascending
                            ? Icons.arrow_upward
                            : _resultSortState == SortState.descending
                            ? Icons.arrow_downward
                            : Icons.sort,
                        size: 16,
                      ),
                    ],
                  ),
                ),),
              ],
              rows: filteredData.map((row) {
                return DataRow(cells: [
                  DataCell(
                    Container(
                      width: 10,
                      child: Text(row['연번']!),
                    ),
                  ),

                  DataCell(Text(row['날짜']!)),
                  DataCell(
                    GestureDetector(
                      onTap: () {
                        if (row['제목'] != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)=>FeedbackDetailPage(
                            title: row['제목'] ?? '제목 없음',
                            content: row['내용'] ?? '내용 없음',
                            author: row['작성자'] ?? '작성자 없음',
                            authorEmail: row['이메일'] ?? '이메일 없음',
                            createdDate: _parseDate(row['날짜']) ?? DateTime.now(),  // Use the correct field for the date
                            statusOptions: ['처리 중', '완료', '보류'], // Example status options

                          ))
                        );
                        } else {
                          // null인 경우에 대한 처리
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('제목 또는 내용이 없습니다.')),
                          );
                        }
                      },
                      child: Text(
                        row['제목'] ?? '제목 없음',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(row['작성자']!)),
                  DataCell(Text(row['처리결과']!)),
                ]);
              }).toList()),
        ))
      ]),
    );
  }
  DateTime? _parseDate(String? dateString) {
    if (dateString == null) {
      return null; // 날짜가 없으면 null 반환
    }
    try {
      List<String> parts = dateString.split('/'); // "2024.12.32"를 "." 기준으로 나누기
      int year = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int day = int.parse(parts[2]);

      return DateTime(year, month, day);
    } catch (e) {
      return DateTime.now();  // 파싱 실패 시 현재 날짜 반환
    }
  }
}

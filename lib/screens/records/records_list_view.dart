import 'package:flutter/material.dart';
import 'package:food_for_later/screens/records/read_record.dart';

class RecordsListView extends StatefulWidget {
  @override
  _RecordsListViewState createState() => _RecordsListViewState();
}

class _RecordsListViewState extends State<RecordsListView> {
  List<Map<String, dynamic>> recordsList = [
    {
      'no': 1,
      'zone': '식단',
      'color': Colors.blueAccent.shade100,
      'date': '2024-09-17',
      'records': [
        {
          'unit': '아침',
          'contents': '맛있었습니다!',
          'images': [
            'assets/step1.jpeg',
          ],
        },
        {
          'unit': '점심',
          'contents': '점심도 맛있었습니다!',
          'images': [
            'assets/step2.jpeg',
          ],
        }
      ]
    },
    {
      'no': 2,
      'zone': '운동',
      'color': Colors.greenAccent.shade100,
      'date': '2024-09-19',
      'records': [
        {
          'unit': '저녁',
          'contents': '운동을 했습니다!',
          'images': ['assets/step3.jpeg'],
        }
      ]
    },
  ];
// 레코드 수정 함수
  void _editRecord(int recordIndex, int recIndex) {
    // 수정 작업을 여기에 추가하세요.
    print('Record $recordIndex, Sub-record $recIndex edited.');
  }

  // 레코드 삭제 함수
  void _deleteRecord(int recordIndex, int recIndex) {
    setState(() {
      recordsList[recordIndex]['records'].removeAt(recIndex);
      // 레코드가 비어 있으면 전체 레코드 삭제
      if (recordsList[recordIndex]['records'].isEmpty) {
        recordsList.removeAt(recordIndex);
      }
    });
    print('Record $recordIndex, Sub-record $recIndex deleted.');
  }

  Widget _buildRecordsSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 500,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: recordsList.length,
              itemBuilder: (context, index) {
                Color getZoneColor(String zone) {
                  switch (zone) {
                    case '식단':
                      return Colors.blue;
                    case '운동':
                      return Colors.green;
                    default:
                      return Colors.grey; // 기본 색상
                  }
                }

                return Column(
                    children: List.generate(
                        recordsList[index]['records'].length, (recIndex) {
                  var rec = recordsList[index]['records'][recIndex];
                  return Dismissible(
                    key: Key('${recordsList[index]['no']}_$recIndex'), // 고유한 키
                    direction: DismissDirection.horizontal, // 좌우 스와이프 가능
                    background: Container(
                      color: Colors.green, // 왼쪽 스와이프 시 수정 표시
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white),
                          Text(' 수정', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red, // 오른쪽 스와이프 시 삭제 표시
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(' 삭제', style: TextStyle(color: Colors.white)),
                          Icon(Icons.delete, color: Colors.white),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        // 왼쪽 스와이프 시 수정 확인 창
                        _editRecord(index, recIndex);
                        return false; // true로 설정하면 수정 기능 후에도 항목이 사라짐
                      } else if (direction == DismissDirection.endToStart) {
                        // 오른쪽 스와이프 시 삭제 확인 창
                        final bool? result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('삭제 확인'),
                              content: Text('정말 삭제하시겠습니까?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text('삭제'),
                                ),
                              ],
                            );
                          },
                        );
                        return result;
                      }
                      return false;
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        // 오른쪽에서 왼쪽으로 스와이프 시 삭제 기능
                        _deleteRecord(index, recIndex);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('레코드가 삭제되었습니다.')),
                        );
                      }
                    },
                    child: InkWell(
                      onTap: () {
                        // 개별 rec 데이터 전달
                        Map<String, dynamic> record = {
                          'record': recordsList[index], // 상위 레코드
                          'rec': rec, // 개별 레코드
                        };
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadRecord(
                              recordData: record,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 컬러 바 추가
                            Container(
                              width: 4,
                              height: 50, // 컬러 바의 높이 설정
                              color: getZoneColor(recordsList[index]['zone']!),
                            ),
                            SizedBox(width: 8), // 컬러 바와 텍스트 사이 간격

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        recordsList[index]['zone'] ??
                                            'Unknown zone',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(width: 4),
                                      Text('|'),
                                      SizedBox(width: 4),
                                      Text(
                                        recordsList[index]['date'] ??
                                            'Unknown Date',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        rec['unit'] ?? 'Unknown Unit',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      SizedBox(width: 4),
                                      Text('|'),
                                      SizedBox(width: 4),
                                      Text(
                                        rec['contents'] ?? 'Unknown contents',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: rec['images'] != null
                                        ? List.generate(
                                            rec['images'].length,
                                            (imgIndex) => Image.asset(
                                              rec['images'][imgIndex],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : [
                                            Container(),
                                          ], // images가 null일 경우 빈 컨테이너를 표시
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }));
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: _buildRecordsSection(),
            ),
          ],
        ),
      ),
    );
  }
}

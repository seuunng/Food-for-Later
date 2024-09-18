import 'package:flutter/material.dart';
import 'package:food_for_later/screens/records/read_record.dart';

class RecordsListView extends StatefulWidget {
  @override
  _RecordsListViewState createState() => _RecordsListViewState();
}

class _RecordsListViewState extends State<RecordsListView> {
  List<Map<String, dynamic>> recordsList = [
    {
      'zone': '식단',
      'unit': '아침',
      'title': '승희네',
      'contents': '맛있었습니다!',
      'date': '2024-05-17',
      'images': ['assets/step1.jpeg', 'assets/step2.jpeg', 'assets/step3.jpeg'],
    },
    {
      'zone': '식단',
      'unit': '점심',
      'title': '지환네',
      'contents': '맛있었습니다!',
      'date': '2024-05-17',
      'images': ['assets/step1.jpeg', 'assets/step2.jpeg', 'assets/step3.jpeg'],
    },
    {
      'zone': '운동',
      'unit': '저녁',
      'title': '옥정네',
      'contents': '맛있었습니다!',
      'date': '2024-05-17',
      'images': ['assets/step1.jpeg', 'assets/step2.jpeg', 'assets/step3.jpeg'],
    },
  ];

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

                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReadRecord(
                               recordData: recordsList,
                                )));
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
                                    recordsList[index]['zone']!,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(width: 4),
                                  Text('|'),
                                  SizedBox(width: 4),
                                  Text(
                                    recordsList[index]['unit']!,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(width: 4),
                                  Text('|'),
                                  SizedBox(width: 4),
                                  Text(
                                    recordsList[index]['date']!,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Text(
                                recordsList[index]['title']!,
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                recordsList[index]['contents']!,
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 10),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: recordsList[index]['images'] != null
                                    ? List.generate(
                                        recordsList[index]['images'].length,
                                        (imgIndex) => Image.asset(
                                          recordsList[index]['images']
                                              [imgIndex],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : [
                                        Container()
                                      ], // images가 null일 경우 빈 컨테이너를 표시
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
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

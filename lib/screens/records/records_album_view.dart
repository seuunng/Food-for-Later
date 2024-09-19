import 'package:flutter/material.dart';
import 'package:food_for_later/screens/records/read_record.dart';

class RecordsAlbumView extends StatefulWidget {
  @override
  _RecordsAlbumViewState createState() => _RecordsAlbumViewState();
}

class _RecordsAlbumViewState extends State<RecordsAlbumView> {
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

  Map<String, dynamic>? _findRecordByImage(String imagePath) {
    for (var record in recordsList) {
      for (var rec in record['records']) {
        if (rec['images'].contains(imagePath)) {
          return {
            'record': record, // 상위 레코드
            'rec': rec        // 해당 이미지가 포함된 개별 레코드
          };
        }
      }
    }
    return null;
  }

  Widget _buildImageGrid() {
    List<String> allImages = [];
    for (var record in recordsList) {
      for (var rec in record['records']) {
        allImages.addAll(List<String>.from(rec['images']));
      }
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 1줄에 4개씩 나열
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        childAspectRatio: 1, // 정사각형으로 만듦
      ),
      itemCount: allImages.length,
      itemBuilder: (context, index) {
        String imagePath = allImages[index];
        Map<String, dynamic>? record = _findRecordByImage(imagePath);

        return GestureDetector(
          onTap: () {
            if (record != null) {
              // print("Found recordsList: ${record}");
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReadRecord(
                    recordData: record,  // 클릭한 이미지의 레코드를 넘김
                  ),
                ),
              );
            }
          },
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            // Expanded는 Column 안에서만 사용
            child: _buildImageGrid(),
          ),
        ],
      ),
    );
  }
}

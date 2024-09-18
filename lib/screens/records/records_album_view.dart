import 'package:flutter/material.dart';
import 'package:food_for_later/screens/records/read_record.dart';

class RecordsAlbumView extends StatefulWidget {
  @override
  _RecordsAlbumViewState createState() => _RecordsAlbumViewState();
}

class _RecordsAlbumViewState extends State< RecordsAlbumView> {
  List<Map<String, dynamic>> recordsList = [
    {
      'zone': '식단',
      'color': Colors.blueAccent.shade100,
      'date': '2024-09-17',
      'records': [
        {
          'unit': '아침',
          'contents': '맛있었습니다!',
          'images': [
            'assets/step1.jpeg',
            'assets/step2.jpeg',
            'assets/step3.jpeg'
          ],
        },
        {
          'unit': '점심',
          'contents': '점심도 맛있었습니다!',
          'images': [
            'assets/step1.jpeg',
            'assets/step2.jpeg',
            'assets/step3.jpeg'
          ],
        }
      ]
    },
    {
      'zone': '운동',
      'color': Colors.greenAccent.shade100,
      'date': '2024-09-19',
      'records': [
        {
          'unit': '저녁',
          'contents': '운동을 했습니다!',
          'images': [
            'assets/step1.jpeg',
            'assets/step2.jpeg',
            'assets/step3.jpeg'
          ],
        }
      ]
    },
  ];

  Widget _buildImageGrid() {
    List<String> allImages = [];
    for (var record in recordsList) {
      allImages.addAll(record['images']);
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
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadRecord(
                  recordData: recordsList,
                ),
              ),
            );
          },
            child: Image.asset(
            allImages[index],
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
          Expanded( // Expanded는 Column 안에서만 사용
            child: _buildImageGrid(),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class RecordsAlbumView extends StatefulWidget {
  @override
  _RecordsAlbumViewState createState() => _RecordsAlbumViewState();
}

class _RecordsAlbumViewState extends State< RecordsAlbumView> {
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
        return Image.asset(
          allImages[index],
          fit: BoxFit.cover,
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
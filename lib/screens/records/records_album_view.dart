import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/screens/records/read_record.dart';

import '../../models/recordModel.dart';

class RecordsAlbumView extends StatefulWidget {
  @override
  _RecordsAlbumViewState createState() => _RecordsAlbumViewState();
}

class _RecordsAlbumViewState extends State<RecordsAlbumView> {
  Map<String, dynamic>? _findRecordByImage(List<RecordModel> recordsList, String imagePath) {
    for (var record in recordsList) {
      for (var rec in record.records) {
        if (rec.images.contains(imagePath)) {
          return {
            'record': record, // 상위 레코드
            'rec': rec        // 해당 이미지가 포함된 개별 레코드
          };
        }
      }
    }
    return null;
  }

  Widget _buildImageGrid(List<RecordModel> recordsList) {
    List<String> allImages = [];
    for (var record in recordsList) {
      for (var rec in record.records) {
        allImages.addAll(List<String>.from(rec.images));
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
        Map<String, dynamic>? record = _findRecordByImage(recordsList, imagePath);


        return GestureDetector(
          onTap: () {
            if (record != null) {
              // print("Found recordsList: ${record}");
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReadRecord(
                    recordId:  record['id'] ?? 'default_record_id',
                  ),
                ),
              );
            }
          },
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.broken_image, size: 50);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('record').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('데이터를 가져오는 중 오류가 발생했습니다.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final recordsList = snapshot.data!.docs.map((doc) {
            return RecordModel.fromJson(
              doc.data() as Map<String, dynamic>,
              id: doc.id,
            );
          }).toList();

          return _buildImageGrid(recordsList);
        },
      ),
    );
  }
}

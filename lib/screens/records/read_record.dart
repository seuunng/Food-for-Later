import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';
import 'package:food_for_later/screens/records/create_record.dart';
import 'package:intl/intl.dart';

import '../../models/recordModel.dart';

class ReadRecord extends StatefulWidget {
  final String recordId; // recordId를 전달받도록 수정

  ReadRecord({required this.recordId});

  @override
  _ReadRecordState createState() => _ReadRecordState();
}

class _ReadRecordState extends State<ReadRecord> {
  @override
  Widget build(BuildContext context) {
    // final recordTitle = widget.recordData;
    // final String category =
    //     widget.recordData['record']['zone'] ?? 'Unknown Category';
    // final String date = widget.recordData['record']['date'] ?? 'Unknown Date';
    // final List<Map<String, dynamic>> records = List<Map<String, dynamic>>.from(
    //     widget.recordData!['record']['records'] ?? []);
    // if (widget.recordData == null || widget.recordData['record'] == null) {
    //   return Scaffold(
    //     appBar: AppBar(title: Text('Record Not Found')),
    //     body: Center(child: Text('No record data available')),
    //   );
    // }
    // print('전달된 recordId: ${widget.recordId}');
    return Scaffold(
      appBar: AppBar(
        title: Text('기록 보기'),
        actions: [
          TextButton(
            child: Text(
              '수정',
              style: TextStyle(
                fontSize: 20, // 글씨 크기를 20으로 설정
              ),
            ),
            onPressed: () async {
              final updatedRecord = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateRecord(
                    recordId: widget.recordId, // 초기 데이터 전달
                    isEditing: true, // 수정 모드로 설정
                  ),
                ),
              );

              if (updatedRecord != null) {
                // 수정된 데이터가 돌아오면 처리
                // 현재 화면을 업데이트하거나 데이터를 반영하는 작업
              }
            },
          ),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('record')
            .doc(widget.recordId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('데이터를 가져오는 중 오류가 발생했습니다.'),
            );
          }
          // Firestore 데이터를 RecordModel로 변환
          final recordData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          // print('Firestore 데이터: $recordData'); // Firestore에서 가져온 데이터 출력

          final record = RecordModel.fromJson(recordData, id: snapshot.data?.id ?? 'unknown');
          // print('RecordModel: $record'); // 기록 모델 데이터 출력
          // print('RecordModel.records: ${record.records}'); // 레코드 리스트 출력

          if (record.records.isEmpty) {
            print('레코드가 비어 있습니다.');
          }


          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('데이터가 없습!니다.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(record.date) ?? 'Unknown Date',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' | ',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${record.zone} 기록',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: record.records.length,
                  itemBuilder: (context, index) {
                    final rec = record.records[index];
                    // print('RecordDetail: $rec');
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                rec.unit ?? 'Unknown Field',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                ' | ',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                rec.contents ?? 'No description',
                                style: TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: rec.images.map((imagePath) {
                              return Image.network(
                                imagePath, // URL 경로를 사용하여 이미지 로드
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text('Error loading image');
                                },
                              );
                            }).toList(),
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:food_for_later/screens/admin_page/admin_main_page.dart';
import 'package:food_for_later/screens/records/create_record.dart';

class ReadRecord extends StatefulWidget {
  final Map<String, dynamic> recordData;

  ReadRecord({required this.recordData});

  @override
  _ReadRecordState createState() => _ReadRecordState();
}

class _ReadRecordState extends State<ReadRecord> {
  @override
  Widget build(BuildContext context) {
    // final recordTitle = widget.recordData;
    final String category =
        widget.recordData['record']['zone'] ?? 'Unknown Category';
    final String date = widget.recordData['record']['date'] ?? 'Unknown Date';
    final List<Map<String, dynamic>> records = List<Map<String, dynamic>>.from(
        widget.recordData!['record']['records'] ?? []);
    if (widget.recordData == null || widget.recordData['record'] == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Record Not Found')),
        body: Center(child: Text('No record data available')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('기록 보기'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedRecord = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateRecord(
                    recordsData: widget.recordData, // 초기 데이터 전달
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
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('$date',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  ' | ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$category 기록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: records.length, // 데이터 세트 수만큼 렌더링
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final String field = record['unit'] ?? 'Unknown Field';
                    final String description =
                        record['contents'] ?? 'No description';
                    final List<String> images =
                        List<String>.from(record['images'] ?? []);

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$field',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  ' | ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$description',
                                  style: TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: images.map((imagePath) {
                                return Image.asset(
                                  imagePath,
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
                          ]),
                    );
                  }))
        ],
      ),
    );
  }
}

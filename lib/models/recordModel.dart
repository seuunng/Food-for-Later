import 'package:cloud_firestore/cloud_firestore.dart';

class RecordModel {
  String id;
  DateTime date;
  String zone;
  List<RecordDetail> records;

  RecordModel({
    required this.id,
    required this.date,
    required this.zone,
    required this.records,
  });

  // Firestore에서 데이터를 가져와서 Record 객체로 변환하는 메서드
  factory RecordModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return RecordModel(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      zone: data['zone'] ?? '',
      records: (data['records'] as List)
          .map((item) => RecordDetail.fromMap(item))
          .toList(),
    );
  }

  // Record 객체를 Firestore에 저장 가능한 Map으로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'zone': zone,
      'records': records.map((item) => item.toMap()).toList(),
    };
  }
}

class RecordDetail {
  String unit;
  String contents;
  List<String> images;

  RecordDetail({
    required this.unit,
    required this.contents,
    required this.images,
  });

  // Firestore에서 데이터를 가져와서 RecordDetail 객체로 변환하는 메서드
  factory RecordDetail.fromMap(Map<String, dynamic> data) {
    return RecordDetail(
      unit: data['unit'] ?? '',
      contents: data['contents'] ?? '',
      images: List<String>.from(data['images'] ?? []),
    );
  }

  // RecordDetail 객체를 Firestore에 저장 가능한 Map으로 변환하는 메서드
  Map<String, dynamic> toMap() {
    return {
      'unit': unit,
      'contents': contents,
      'images': images,
    };
  }
}
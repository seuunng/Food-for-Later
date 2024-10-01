import 'package:cloud_firestore/cloud_firestore.dart';

class DefaultFoodModel {
  final String id; // 고유 ID
  final String categories; // 대분류 카테고리 이름
  final List<Map<String, dynamic>> itemsByCategory; // 소분류 아이템 이름
  final DateTime? expirationDate; // 소비기한
  final DateTime? shelfLife; // 유통기한

  DefaultFoodModel({
    required this.id,
    required this.categories,
    required this.itemsByCategory,
    this.expirationDate, // 소비기한
    this.shelfLife, // 유통기한
  });

  // Firestore에서 데이터를 가져올 때 사용하는 팩토리 메서드
  factory DefaultFoodModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DefaultFoodModel(
      id: doc.id,
      categories: data['categories'] as String,
      itemsByCategory: List<Map<String, dynamic>>.from(data['itemsByCategory'] as List<dynamic>), // Firestore에서 List<String>으로 변환
      expirationDate: data['expirationDate'] != null
          ? (data['expirationDate'] as Timestamp).toDate()
          : null,
      shelfLife: data['shelfLife'] != null
          ? (data['shelfLife'] as Timestamp).toDate()
          : null,
    );
  }

  // Firestore에 저장할 때 Map 형태로 변환하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'categories': categories,
      'itemsByCategory': itemsByCategory,
      'expirationDate':
          expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
      'shelfLife': shelfLife != null ? Timestamp.fromDate(shelfLife!) : null,
    };
  }
}

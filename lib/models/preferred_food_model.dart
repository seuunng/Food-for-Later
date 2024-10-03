import 'package:cloud_firestore/cloud_firestore.dart';

class PreferredFoodModel {
  final int id;
  final Map<String, List<String>> category;

  PreferredFoodModel({
    required this.id,
    required this.category,
  });

  factory PreferredFoodModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, List<String>> categoryMap = {};

    if (data['category'] != null && data['category'] is Map<String, dynamic>) {
      (data['category'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List) {
          categoryMap[key] = List<String>.from(value); // List<String>으로 변환
        }
      });
    }

    return PreferredFoodModel(
      id: data['id'],
      category: categoryMap,
    );
    return PreferredFoodModel(
      id: data['id'],
      category: data['category'],
    );
  }

  // Firestore에 데이터를 저장할 때 사용하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'category': category,
    };
  }
}

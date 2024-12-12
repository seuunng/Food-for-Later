import 'package:cloud_firestore/cloud_firestore.dart';

class PreferredFoodModel {
  final String userId;
  final Map<String, List<String>> category;

  PreferredFoodModel({
    required this.userId,
    required this.category,
  });

  factory PreferredFoodModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // category를 Map<String, List<String>>으로 변환
    final category = (data['category'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
        key,
        List<String>.from(value), // List<String>으로 변환
      ),
    );

    return PreferredFoodModel(
      userId: data['userId'] as String,
      category: category,
    );
  }

  // Firestore에 데이터를 저장할 때 사용하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'category': category,
    };
  }
}

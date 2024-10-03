import 'package:cloud_firestore/cloud_firestore.dart';

class FridgeCategory {
  final String id; // Firestore 문서 ID
  final List<Map<String, String>> categoryName; //냉장고:카테고리
  final String fridgeId; // 연결된 Fridge ID

  FridgeCategory({
    required this.id,
    required this.categoryName,
    required this.fridgeId,
  });

  // Firestore 데이터를 가져올 때 사용하는 팩토리 메서드
  factory FridgeCategory.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FridgeCategory(
      id: doc.id, // Firestore 문서의 ID
      fridgeId: data['FridgeID'], // Firestore 필드명
      categoryName: List<Map<String, String>>.from(data['CategoryName'].map((item) => Map<String, String>.from(item))),
    );
  }

  // Firestore에 데이터를 저장할 때 사용하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'FridgeID': fridgeId, // Firestore에 저장할 필드
      'CategoryName': categoryName.map((item) => Map<String, String>.from(item)).toList(), // Firestore에 저장할 필드
    };
  }
}

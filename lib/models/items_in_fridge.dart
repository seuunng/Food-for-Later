import 'package:cloud_firestore/cloud_firestore.dart';

class ItemsInFridge {
  final String id;
  final String fridgeId; // 연결된 Fridge ID
  final String fridgeCategoryId; // 연결된 Fridge ID
  final List<Map<String, String>> items; // 냉장고:카테고리:아이템

  ItemsInFridge({
    required this.id,
    required this.fridgeId,
    required this.fridgeCategoryId,
    required this.items,
  });

  // Firestore 데이터를 가져올 때 사용하는 팩토리 메서드
  factory ItemsInFridge.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ItemsInFridge(
      id: doc.id,
      fridgeId: data['FridgeId'], // Firestore 필드명
      fridgeCategoryId: data['FridgeCategoryId'],
      items: data['Items'],
    );
  }

  // Firestore에 데이터를 저장할 때 사용하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'FridgeId': fridgeId, // Firestore에 저장할 필드
      'fridgeCategoryId': fridgeCategoryId,
      'Items': items,
    };
  }
}
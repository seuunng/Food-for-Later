import 'package:cloud_firestore/cloud_firestore.dart';

class ItemsInShoppingList {
  final String id;
  final List<Map<String, String>> items; //카테고리:아이템
  final String userId; // 사용자의 ID

  ItemsInShoppingList({
    required this.id,
    required this.items,
    required this.userId,
  });

  // Firestore 데이터를 가져올 때 사용하는 팩토리 메서드
  factory ItemsInShoppingList.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ItemsInShoppingList(
      id: doc.id,
      items: List<Map<String, String>>.from(
        (data['Items'] as List).map(
              (item) => Map<String, String>.from(item as Map),
        ),
      ),
      userId: data['UserID'], // Firestore 필드명
    );
  }

  // Firestore에 데이터를 저장할 때 사용하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'Items': items,
      'UserID': userId, // Firestore에 저장할 필드
    };
  }
}
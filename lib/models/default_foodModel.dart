import 'package:cloud_firestore/cloud_firestore.dart';

class DefaultFoodModel {
  final String id; // 고유 ID
  final String categories; // 대분류 카테고리 이름
  final List<String> itemsByCategory; // 소분류 아이템 이름
  final bool isDisabled; // 비활성화 여부
  final bool isDefaultFridgeCategory; // 기본 냉장고 카테고리 여부
  final bool isShoppingListCategory; // 기본 냉장고 카테고리 여부
  final DateTime? expirationDate; // 소비기한
  final DateTime? shelfLife; // 유통기한

  DefaultFoodModel({
    required this.id,
    required this.categories,
    required this.itemsByCategory,
    this.isDisabled = false, // 기본값은 활성화 상태
    this.isDefaultFridgeCategory = false, // 기본값은 기본 냉장고 카테고리가 아님
    this.isShoppingListCategory = false, // 기본값은 기본 냉장고 카테고리가 아님
    this.expirationDate, // 소비기한
    this.shelfLife, // 유통기한
  });

  // Firestore에서 데이터를 가져올 때 사용하는 팩토리 메서드
  factory DefaultFoodModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DefaultFoodModel(
      id: doc.id,
      categories: data['categories'] as String,
      itemsByCategory: List<String>.from(data['itemsByCategory'] as List<dynamic>), // Firestore에서 List<String>으로 변환
      isDisabled: data['isDisabled'] as bool? ?? false,
      isDefaultFridgeCategory:
      data['isDefaultFridgeCategory'] as bool? ?? false,
      isShoppingListCategory:
      data['isShoppingListCategory'] as bool? ?? false,
      expirationDate: data['expirationDate'] != null
          ? (data['expirationDate'] as Timestamp).toDate()
          : null, // Firestore에서 Timestamp로 저장된 경우 DateTime으로 변환
      shelfLife: data['shelfLife'] != null
          ? (data['shelfLife'] as Timestamp).toDate()
          : null, // Firestore에서 Timestamp로 저장된 경우 DateTime으로 변환
    );
  }

  // Firestore에 저장할 때 Map 형태로 변환하는 메서드
  Map<String, dynamic> toFirestore() {
    return {
      'categories': categories,
      'itemsByCategory': itemsByCategory,
      'isDisabled': isDisabled,
      'isDefaultFridgeCategory': isDefaultFridgeCategory,
      'isShoppingListCategory': isShoppingListCategory,
      'expirationDate':
          expirationDate != null ? Timestamp.fromDate(expirationDate!) : null,
      'shelfLife': shelfLife != null ? Timestamp.fromDate(shelfLife!) : null,
    };
  }
}
